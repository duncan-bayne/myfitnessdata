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

(in-package :myfitnessdata)

(defmacro run-tests-and-quit (&body tests)
  `(if (lisp-unit:run-tests ,@tests)
       (sb-ext:quit :unix-status 1)
     (sb-ext:quit :unix-status 0)))

(defmacro define-test-with-cookie-jar (test-name cookie-domain cookie-name test)
  `(lisp-unit:define-test
    ,test-name
    (let* ((cookie-jar (make-instance 'drakma:cookie-jar))
	   (cookie ,(if (and cookie-name cookie-domain)
			`(make-instance 'drakma:cookie :name ,cookie-name :domain ,cookie-domain)
		      `nil)))
      (if cookie
	  (setf (drakma:cookie-jar-cookies cookie-jar) (list cookie)))
      ,test)))

(define-test-with-cookie-jar
  logged-in-nil-when-no-cookies
  nil
  nil
  (lisp-unit:assert-false (logged-in? cookie-jar)))

(define-test-with-cookie-jar
  logged-in-nil-when-cookies-from-wrong-domain
  "www.example.com" 
  "known_user" 
  (lisp-unit:assert-false (logged-in? cookie-jar)))

(define-test-with-cookie-jar 
  logged-in-t-when-cookies-from-right-domain
  "www.myfitnesspal.com" 
  "known_user"
  (lisp-unit:assert-true (logged-in? cookie-jar)))

(lisp-unit:define-test 
 make-csv-from-list
 (let ((list '(("1/1/2000" "79.2") ("2/1/2000" "23.4"))))
   (lisp-unit:assert-equal (format nil "1/1/2000,79.2~%2/1/2000,23.4")
			   (make-csv list))))

(lisp-unit:define-test 
 make-csv-from-list-is-sorted
 (let ((list '(("2/1/2000" "23.4") ("1/1/2000" "79.2"))))
   (lisp-unit:assert-equal (format nil "1/1/2000,79.2~%2/1/2000,23.4")
			   (make-csv list))))
