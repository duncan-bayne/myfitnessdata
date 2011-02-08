(require :sb-posix)
(load (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname)))
(ql:quickload '("drakma" "closure-html" "cxml-stp"))

(defun show-usage () 
  (format t "Usage: myfitnessdata USERNAME PASSWORD PATH~%~%")
  (format t "  USERNAME  Your MyFitnessPal username~%")
  (format t "  PASSWORD  Your MyFitnessPal password~%")
  (format t "  PATH      The path into which to place the CSV files~%~%")
  (format t "Example:~%~%")
  (format t "  myfitnessdata bob b0bsp4ss! c:\\Users\\bob\\fitness~%~%")
  (format t "This will log into the MyFitnessPal site with the username 'bob' and the~%")
  (format t "password 'b0bsp4ss!'.  It will then scrape data into CSV files, and put~%")
  (format t "those files into the directory '/home/bob/fitness', overwriting existing~%")
  (format t "files.~%~%"))

(defun login (username password)
  (setq cookie-jar (make-instance 'drakma:cookie-jar))
  (drakma:http-request "http://www.myfitnesspal.com/account/login"
		       :method :post
		       :parameters `(("username" . ,username) ("password" . ,password))
		       :cookie-jar cookie-jar)
  cookie-jar)

(defun get-page (page-num cookie-jar)
  (let ((url (concatenate 'string "http://www.myfitnesspal.com/measurements/edit?type=1&page=" (write-to-string page-num))))
    (format t "Fetching ~A~%" url)
    (let ((body (drakma:http-request url :cookie-jar cookie-jar)))
      (if (search "No measurements found." body)
	  nil
	body))))

(defun scrape-body (body)
  (let ((valid-xhtml (chtml:parse body (cxml:make-string-sink))))
    (let ((xhtml-tree (chtml:parse valid-xhtml (cxml-stp:make-builder))))
      (scrape-xhtml xhtml-tree))))

(defun scrape-xhtml (xhtml-tree)
  (setq results nil)
  (stp:do-recursively (element xhtml-tree)
		      (when (and (typep element 'stp:element)
				 (equal (stp:local-name element) "tr"))
			(if (scrape-row element)
			    (setq results (append results (list (scrape-row element)))))))
  results)			  

(defun scrape-row (row)
  (if (equal 4 (stp:number-of-children row))
      (let ((measurement-type (nth-child-data 0 row))
	    (measurement-date (nth-child-data 1 row))
	    (measurement-value (nth-child-data 2 row)))
	(if (not (equal measurement-type "Measurement"))
	    (cons measurement-date measurement-value)))))

(defun nth-child-data (number row)
  (stp:data (stp:nth-child 0 (stp:nth-child number row))))

(defun scrape-page (page-num cookie-jar)
  (let ((body (get-page page-num cookie-jar)))
    (if body
	(append (scrape-body body)
		(scrape-page (+ 1 page-num) cookie-jar)))))

(defun write-csv (data path)
  (format t "Would write CSV to ~A: ~A" path data)) 

(if (= (length sb-ext:*posix-argv*) 3)
    (let* ((username (nth 0 sb-ext:*posix-argv*))
	   (password (nth 1 sb-ext:*posix-argv*))
	   (path (nth 2 sb-ext:*posix-argv*))
	   (cookie-jar (login username password)))
      (write-csv (scrape-page 1 cookie-jar) path))
  (show-usage))
