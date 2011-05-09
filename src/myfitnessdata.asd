;;; -*- Mode: Lisp -*-

(defpackage :myfitnessdata-system (:use :cl :asdf))
(in-package :myfitnessdata-system)

(asdf:defsystem myfitnessdata
  :version "0.1"
  :author "dhgbayne@gmail.com"
  :maintainer "leo.zovic@gmail.com"
  :licence "GPL/LGPL Dual"
  :description "HTML page-scraper for MyFitnessPal"
  :depends-on (:sb-posix :drakma :closure-html :cxml-stp :net-telent-date :lisp-unit)
  :components ((:file "myfitnessdata")
	       (:file "tests" :depends-on ("myfitnessdata"))
	       (:file "run-tests" :depends-on ("myfitnessdata" "tests"))))