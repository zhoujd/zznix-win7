;;;; $Id: illustrations.lisp,v 1.6 2007/10/01 16:24:10 xach Exp $

(defpackage #:vecto-illustrations
  (:use #:cl #:vecto))

(in-package #:vecto-illustrations)

(defun x (point)
  (car point))

(defun y (point)
  (cdr point))

(defun annotated-path (&rest points)
  (with-graphics-state
    (set-rgb-stroke 0.5 0.5 0.5)
    (set-rgb-fill 0.5 0.5 0.5)
    (set-line-width 2)
    (dolist (point (remove-duplicates points :test 'equal))
      (centered-circle-path (x point) (y point) 3))
    (fill-path)
    (move-to (x (first points)) (y (first points)))
    (dolist (point (rest points))
      (line-to (x point) (y point)))
    (stroke)))


(defun join-style (style file)
  (with-canvas (:width 160 :height 165)
    (set-rgb-fill 1 1 1)
    (clear-canvas)
    (set-rgb-stroke 0 0 0)
    (set-line-width 20)
    (move-to 20 20)
    (line-to 80 140)
    (line-to 140 20)
    (set-line-join style)
    (stroke)
    (annotated-path '(20 . 20)
                    '(80 . 140)
                    '(140 . 20))
    (save-png file)))


(defun cap-style (style file)
  (with-canvas (:width 40 :height 100)
    (set-rgb-fill 1 1 1)
    (clear-canvas)
    (set-rgb-stroke 0 0 0)
    (set-line-width 20)
    (move-to 20 20)
    (line-to 20 80)
    (set-line-cap style)
    (stroke)
    (annotated-path '(20 . 20) '(20 . 80))
    (save-png file)))



(defun closed-subpaths (closep file)
  (with-canvas (:width 160 :height 160)
    (set-rgb-fill 1 1 1)
    (clear-canvas)
    (set-rgb-stroke 0 0 0)
    (set-line-width 20)
    (move-to 20 20)
    (line-to 20 140)
    (line-to 140 140)
    (line-to 140 20)
    (line-to 20 20)
    (when closep
      (close-subpath))
    (stroke)
    (annotated-path '(20 . 20)
                    '(20 . 140)
                    '(140 . 140)
                    '(140 . 20)
                    '(20 . 20))
    (save-png file)))

(defun dash-paths (array phase cap-style file)
  (with-canvas (:width 160 :height 40)
    (set-rgb-fill 1 1 1)
    (clear-canvas)
    (set-rgb-stroke 0 0 0)
    (set-line-width 20)
    (with-graphics-state
      (set-dash-pattern array phase)
      (set-line-cap cap-style)
      (move-to 20 20)
      (line-to 140 20)
      (stroke))
    (annotated-path '(20 . 20) '(140 . 20))
    (save-png file)))
  

(defun simple-clipping-path (file &key clip-circle clip-rounded-rectangle)
  (with-canvas (:width 100 :height 100)
    (let ((x0 45)
          (y 45)
          (r 40))
      (set-rgb-fill 1 1 1)
      (clear-canvas)
      (with-graphics-state
        (set-rgb-fill 0.9 0.9 0.9)
        (rectangle 10 10 80 80)
        (fill-path))
      (with-graphics-state
        (when clip-circle
          (centered-circle-path x0 y r)
          (clip-path)
          (end-path-no-op))
        (when clip-rounded-rectangle
          (rounded-rectangle 45 25 50 50 10 10) 
          (clip-path)
          (end-path-no-op))
        (set-rgb-fill 1 0 0)
        (set-rgb-stroke 1 1 0)
        (rectangle 10 10 80 80)
        (fill-path))
      (when clip-circle
        (with-graphics-state
          (set-rgb-stroke 0.5 0.5 0.5)
          (set-dash-pattern #(5) 0)
          (set-line-width 1)
          (centered-circle-path x0 y r)
          (stroke)))
      (when clip-rounded-rectangle
        (with-graphics-state
          (set-rgb-stroke 0.5 0.5 0.5)
          (set-dash-pattern #(5) 0)
          (set-line-width 1)
          (rounded-rectangle 45 25 50 50 10 10) 
          (stroke)))
      (save-png file))))
  
(defun arc-demo (file)
  (flet ((point (x y)
           (with-graphics-state
             (set-rgb-fill 0 0 0)
             (centered-circle-path x y 3)
             (fill-path))))
    (with-canvas (:width 150 :height 150)
      (translate 10 10)
      (let* ((theta1 (* (/ pi 180) 20))
             (theta2 (* (/ pi 180) 80))
             (theta3 (/ (+ theta1 theta2) 2))
             (radius 120)
             (x1 (* (+ radius 10) (cos theta1)))
             (y1 (* (+ radius 10) (sin theta1)))
             (x2 (* (+ radius 10) (cos theta2)))
             (y2 (* (+ radius 10) (sin theta2))))
        (with-graphics-state
          (set-rgb-stroke 0.5 0.5 0.5)
          (set-dash-pattern #(3 3) 0)
          (move-to 0 0)
          (line-to x1 y1)
          (stroke)
          (move-to 0 0)
          (line-to x2 y2)
          (stroke)
          (move-to -500 0)
          (line-to 500 0)
          (stroke))
        (set-rgb-stroke 1 0 0)
        (set-line-width 1)
        (arc 0 0 80 0 theta1)
        (stroke)
        (set-rgb-stroke 0 0 1)
        (arc 0 0 100 0 theta2)
        (stroke)
        (set-rgb-stroke 0 1 0)
        (move-to 0 0)
        (line-to (* radius (cos theta3))
                 (* radius (sin theta3)))
        (stroke)
        (set-line-width 2)
        (set-rgb-stroke 0 0 0)
        (arc 0 0 radius theta1 theta2)
        (stroke)
        (point (* radius (cos theta1))
               (* radius (sin theta1)))
        (point (* radius (cos theta2))
               (* radius (sin theta2)))
        (save-png file)))))

(defun pie-wedge (file)
  (with-canvas (:width 80 :height 60)
    (let ((x 0) (y 0)
          (radius 70)
          (angle1 (* (/ pi 180) 15))
          (angle2 (* (/ pi 180) 45)))
      (translate 5 5)
      (set-rgb-fill 1 1 1)
      (move-to 0 0)
      (arc x y radius angle1 angle2)
      (fill-and-stroke)
      (save-png file))))

(defun wiper (file)
  (with-canvas (:width 70 :height 70)
    (let ((x 0) (y 0)
          (r1 30) (r2 60)
          (angle1 0)
          (angle2 (* (/ pi 180) 90)))
      (translate 5 5)
      (set-rgba-fill 1 1 1 0.75)
      (arc x y r1 angle1 angle2)
      (arcn x y r2 angle2 angle1)
      (fill-and-stroke)
      (save-png file))))

          
      
      

(defun make-illustrations ()
  (cap-style :butt "cap-style-butt.png")
  (cap-style :square "cap-style-square.png")
  (cap-style :round "cap-style-round.png")
  (join-style :miter "join-style-miter.png")
  (join-style :bevel "join-style-bevel.png")
  (join-style :round "join-style-round.png")
  (closed-subpaths nil "open-subpath.png")
  (closed-subpaths t "closed-subpath.png")
  (dash-paths #() 0 :butt "dash-pattern-none.png")
  (dash-paths #(30 30) 0 :butt "dash-pattern-a.png")
  (dash-paths #(30 30) 15 :butt "dash-pattern-b.png")
  (dash-paths #(10 20 10 40) 0 :butt "dash-pattern-c.png")
  (dash-paths #(10 20 10 40) 13 :butt "dash-pattern-d.png")
  (dash-paths #(30 30) 0 :round "dash-pattern-e.png")
  (simple-clipping-path "clip-unclipped.png")
  (simple-clipping-path "clip-to-circle.png" :clip-circle t)
  (simple-clipping-path "clip-to-rectangle.png" :clip-rounded-rectangle t)
  (simple-clipping-path "clip-to-both.png"
                        :clip-circle t
                        :clip-rounded-rectangle t))
