;; MyFitnessData - a CSV web scraper for the MyFitnessPal website.
;; Copyright (C) 2011 "Duncan Bayne" <dhgbayne@gmail.com>
;; 
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Lesser General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Lesser General Public License for more details.
;; 
;; You should have received a copy of the GNU Lesser General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>


(defpackage :myfitnessdata
  (:use :common-lisp :drakma)
  (:export #:main))

(in-package :myfitnessdata)

(defvar help (list "MyFitnessData - a CSV web scraper for the MyFitnessPal website."
		   "Copyright (C) 2011 \"Duncan Bayne\" <dhgbayne@gmail.com>"
		   "This program is distributed in the hope that it will be useful,"
		   "but WITHOUT ANY WARRANTY; without even the implied warranty of"
		   "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
		   "GNU Lesser General Public License for more details."
		   "Usage: myfitnessdata USERNAME PASSWORD WEIGHTS_FILENAME"
		   "  USERNAME  Your MyFitnessPal username"
		   "  PASSWORD  Your MyFitnessPal password"
		   "  FILENAME  The pathname of the CSV file to write"
		   "Example:"
		   "  myfitnessdata bob b0bsp4ss! c:\\Users\\bob\\weights.csv"
		   "This will log into the MyFitnessPal site with the username 'bob' and the"
		   "password 'b0bsp4ss!'.  It will then scrape weight data into the file"
		   "'c:\\Users\\bob\\weights.csv', overwriting it if it exists."))

(defun login (username password)
  "Logs in to www.myfitnesspal.com.  Returns a cookie-jar containing authentication details."
  (let ((cookie-jar (make-instance 'cookie-jar)))
    (http-request "http://www.myfitnesspal.com/account/login"
			 :method :post
			 :parameters `(("username" . ,username) ("password" . ,password))
			 :cookie-jar cookie-jar)
    cookie-jar))

(defun logged-in? (cookie-jar)	     
  "Returns true if a cookie-jar contains login information for www.myfitnesspal.com, and nil otherwise."
  (let ((cookies (cookie-jar-cookies cookie-jar)))
    (and cookies
	 (loop for c in cookies
	       always (and (equal (cookie-name c) "known_user")
			   (equal (cookie-domain c) "www.myfitnesspal.com")
			   (cookie-value c))))))

(defun get-page (page-num cookie-jar)
  "Downloads a potentially invalid HTML page containing data to scrape.  Returns a string containing the HTML."
  (let* ((url (format nil "http://www.myfitnesspal.com/measurements/edit?type=1&page=~D" page-num))
	 (body (http-request url :cookie-jar cookie-jar)))
      (unless (search "No measurements found." body) body)))

(defun scrape-body (body)
  "Scrapes data from a potentially invalid HTML document, returning a list of lists of values."
  (let ((valid-xhtml (chtml:parse body (cxml:make-string-sink)))
	(xhtml-tree (chtml:parse valid-xhtml (cxml-stp:make-builder))))
    (scrape-xhtml xhtml-tree)))

(defun scrape-xhtml (xhtml-tree)
  "Scrapes data from an XHTML tree, returning a list of lists of values."
  (let ((results nil))
    (stp:do-recursively (element xhtml-tree)
      (when (and (typep element 'stp:element)
		 (equal (stp:local-name element) "tr"))
	(if (scrape-row element)
	    (setq results (append results (list (scrape-row element)))))))
    results))

(defun scrape-row (row)
  "Scrapes data from a table row into a list of values."
  (if (equal 4 (stp:number-of-children row))
      (let ((measurement-type (nth-child-data 0 row))
	    (measurement-date (nth-child-data 1 row))
	    (measurement-value (nth-child-data 2 row)))
	(if (not (equal measurement-type "Measurement"))
	    (list measurement-date measurement-value)))))

(defun nth-child-data (number row) 
  (stp:data (stp:nth-child 0 (stp:nth-child number row))))

(defun scrape-page (page-num cookie-jar)
  "Iteratively scrapes data from a page and all successive pages.  Returns a list of lists of values."
  (loop for i from page-num
	if (get-page i cookie-jar) collect it into pg
	  else return pg))

(defun show-login-failure ()
  (format t "Login failed.~%"))

(defun write-csv (data csv-pathname)
  "Takes a list of lists of values, converts them to CSV, and writes them to a file."
  (ensure-directories-exist csv-pathname)
  (with-open-file (stream csv-pathname 
			  :direction :output
			  :if-exists :overwrite
			  :if-does-not-exist :create)
    (format stream (make-csv data))))

(defun make-csv (list)
  "Takes a list of lists of values, and returns a string containing a CSV file representing each top-level list as a row."
  (let ((sorted-list (sort (copy-list list) #'first-column-as-date-ascending)))
    (format nil "~{~{~A~^,~}~^~%~}" sorted-list)))

(defun first-column-as-date-ascending (first-row second-row)
  "Compares two rows by their first column, which is parsed as a time."
  (< (net.telent.date:parse-time (car first-row))
     (net.telent.date:parse-time (car second-row))))

(defun scrape (username password csv-pathname)
  "Attempts to log in, and if successful scrapes all data to the file specified by csv-pathname."
  (let ((cookie-jar (login username password)))
    (if (logged-in? cookie-jar)
	(write-csv (scrape-page 1 cookie-jar) csv-pathname)
      (show-login-failure))))

(defun main (args)
  "The entry point for the application when compiled with buildapp."
  (if (= (length args) 4)
      (destructuring-bind (i username password csv-pathname) args
	(scrape username password csv-pathname))
      (format t "~{~a~%~}" help)))

