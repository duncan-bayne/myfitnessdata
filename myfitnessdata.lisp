(require :sb-posix)
(load (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname)))
(ql:quickload '("drakma" "closure-html" "cxml-stp"))

(defun show-usage () 
  (format t "Usage: myfitnessdata USERNAME PASSWORD~%~%")
  (format t "  USERNAME  Your MyFitnessPal username~%")
  (format t "  PASSWORD  Your MyFitnessPal password~%~%")
  (format t "Example:~%~%")
  (format t "  ./myfitnessdata bob b0bsp4ss! weights.csv~%~%"))

(defun get-page (page-num username password)
  (let ((cookie-jar (make-instance 'drakma:cookie-jar)))
    (drakma:http-request "http://www.myfitnesspal.com/account/login"
  			 :method :post
  			 :parameters `(("username" . ,username) ("password" . ,password))
  			 :cookie-jar cookie-jar)
    (let ((url (concatenate 'string "http://www.myfitnesspal.com/measurements/edit?type=1&page=" (write-to-string page-num))))
      (format t "Fetching page ~a~%" url)
      (let ((body (drakma:http-request url :cookie-jar cookie-jar)))
	(if (search "No measurements found." body)
	    nil
	  body)))))

(defun scrape-body (body)
  (let ((valid-xhtml (chtml:parse body (cxml:make-string-sink))))
    (let ((xhtml-tree (cxml:parse valid-xhtml (cxml-xmls:make-xmls-builder)))))))

(defun scrape-page (page-num username password)
  (let ((body (get-page page-num username password)))
    (if (not (string= nil body))
	(progn
	  (scrape-body body)
	  (scrape-page (+ 1 page-num) username password)))))

(if (= (length sb-ext:*posix-argv*) 3)
    (let ((username (nth 0 sb-ext:*posix-argv*))
	  (password (nth 1 sb-ext:*posix-argv*)))
      (scrape-page 1 username password))
  (show-usage))
