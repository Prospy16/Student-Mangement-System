# Student-Mangement-System

#  Student Management System (SMS)

An end-to-end SQL-based database project that models how institutions manage students, courses, departments, instructors, and enrollments complete with real-time reporting and clean relational design.

---

##  Project Overview

**Objective:**  
To design and build a relational database for a Student Management System using SQL. This system enables users to:
- Add and manage student data
- Assign students to courses and departments
- Link instructors to course offerings
- Generate insightful reports using dynamic SQL queries

---

##  Tables Created

###  Students
- `Student_id` (INT, PK)
- `First_name` (VARCHAR)
- `Last_name` (VARCHAR)
- `Gender` (CHAR)
- `Date_of_birth` (DATE)
- `Department_id` (FK → Departments)

###  Departments
- `Department_id` (VARCHAR, PK)
- `Department_name` (VARCHAR)

###  Courses
- `Course_id` (VARCHAR, PK)
- `Course_name` (VARCHAR)
- `Department_id` (FK → Departments)
- `Instructor_id` (FK → Instructors)

###  Instructors
- `Instructor_id` (INT, PK)
- `First_name` (VARCHAR)
- `Last_name` (VARCHAR)
- `Email` (VARCHAR)

###  Enrollments
- `Enrollment_id` (INT, PK)
- `Student_id` (FK → Students)
- `Course_id` (FK → Courses)
- `Enrollment_date` (DATE)

---
CREATING THE TABLES
```

CREATE TABLE Departments(
  Department_id VARCHAR(10) PRIMARY KEY NOT NULL,
  Department_name VARCHAR(30)
);

CREATE TABLE Instructors(
  Instructor_id INT PRIMARY KEY NOT NULL,
  First_name VARCHAR(20),
  Last_name VARCHAR(20),
  Email VARCHAR(50)
);

CREATE TABLE Courses(
  Course_id VARCHAR(10) PRIMARY KEY NOT NULL,
  Course_name VARCHAR(25),
  Department_id VARCHAR(10) REFERENCES Departments(Department_id),
  Instructor_id INT REFERENCES Instructors(Instructor_id)
);

CREATE TABLE Students(
  Student_id INT PRIMARY KEY NOT NULL,
  First_name VARCHAR(20),
  Last_name VARCHAR(20),
  Gender CHAR(1),
  Date_of_birth DATE,
  Department_id VARCHAR(10) REFERENCES Departments(Department_id)
);

CREATE TABLE Enrollments(
  Enrollment_id INT PRIMARY KEY NOT NULL,
  Student_id INT REFERENCES Students(Student_id),
  Course_id VARCHAR(10) REFERENCES Courses(Course_id),
  Enrollment_date DATE
);

```
---
## SQL Queries
- How many students are enrolled in each course
  
   
```
SELECT C.Course_name, COUNT(E.Enrollment_id) AS total_enrollment
FROM Students S
JOIN Enrollments E ON S.Student_id = E.Student_id
JOIN Courses C ON C.Course_id = E.Course_id
GROUP BY C.Course_name
ORDER BY total_enrollment DESC;


```
--- 
- Which students are enrolled in multiple courses and which courses are they taking?
```
WITH multiple_course AS (
    SELECT  E.Student_id,
            COUNT(E.Course_id) AS no_of_courses
    FROM Enrollments E
    GROUP BY E.Student_id
    HAVING COUNT(E.Course_id) > 1
)
SELECT  S.Student_id,
        S.First_name,
        S.Last_name,
        C.Course_name
FROM multiple_course M
JOIN Students    S ON S.Student_id = M.Student_id
JOIN Enrollments E ON S.Student_id = E.Student_id
JOIN Courses     C ON C.Course_id  = E.Course_id
ORDER BY S.Student_id, C.Course_name DESC;
```
---
- What is the total number of students per department across all courses

  ```
  SELECT D.Department_name,
       COUNT(S.Student_id) AS total_students
  FROM Students S
  JOIN Departments D ON S.Department_id = D.Department_id
  GROUP BY D.Department_name
  ORDER BY total_students DESC;
  
---
- Which courses have the highest number of enrollments
  ```
  SELECT C.Course_name,
       COUNT(E.Enrollment_id) AS total_enrollments
  FROM Courses C
  JOIN Enrollments E ON C.Course_id = E.Course_id
  GROUP BY C.Course_name
  ORDER BY total_enrollments DESC
  LIMIT 4;


---
- Which department has the least number of students
  ```
  SELECT D.Department_name,
       COUNT(S.Student_id) AS total_students
  FROM Departments D
  JOIN Students    S ON D.Department_id = S.Department_id
  GROUP BY D.Department_name
  ORDER BY total_students
  LIMIT 1;

  
---
  - Are there any student not enrolled in any course?
  ```
  SELECT S.Student_id,
       CONCAT(S.First_name, ' ', S.Last_name) AS full_name
  FROM Students S
  LEFT JOIN Enrollments E ON S.Student_id = E.Student_id
  WHERE E.Enrollment_id IS NULL;

```
---
- How many classes does each students take on an average?
```
WITH course_counts AS (
    SELECT E.Student_id,
           COUNT(E.Course_id) AS courses_taken
    FROM Enrollments E
    GROUP BY E.Student_id
)
SELECT ROUND(AVG(courses_taken)) AS avg_courses_per_student
FROM course_counts;
```
---
- What is the gender of students across courses and instructors
```
SELECT C.Course_name,
       CONCAT(I.First_name, ' ', I.Last_name) AS instructor,
       S.Gender,
       COUNT(*) AS total
FROM Students     S
JOIN Enrollments  E ON S.Student_id  = E.Student_id
JOIN Courses      C ON C.Course_id   = E.Course_id
JOIN Instructors  I ON C.Instructor_id = I.Instructor_id
GROUP BY C.Course_name, instructor, S.Gender
ORDER BY C.Course_name, S.Gender;

```
---
- Which course has the highest male or female students enrolled
```
  WITH course_per_gender AS (
    SELECT S.Gender,
           C.Course_name,
           COUNT(E.Enrollment_id) AS total_enrollments,
           ROW_NUMBER() OVER (
               PARTITION BY S.Gender
               ORDER BY COUNT(E.Enrollment_id) DESC
           ) AS gender_rank
    FROM Students     S
    JOIN Enrollments  E ON S.Student_id = E.Student_id
    JOIN Courses      C ON C.Course_id  = E.Course_id
    GROUP BY S.Gender, C.Course_name
 )
SELECT Gender,
       Course_name,
       total_enrollments
FROM course_per_gender
WHERE gender_rank = 1;

```
---
## Insights
- Fishery has the least number of students  only 1 student enrolled.
- Some students are not enrolled in any course despite being registered.
- Mass Communication and Data Analysis have the highest student population.
-Each student takes an average of about 2 courses.
- Some departments have low visibility or engagement compared to others

  ---
## Recommendations
- Promote low-enrollment departments like Fishery through orientation, better course marketing, or curriculum review.
- Investigate why some students aren't enrolled in any course,  check for registration errors or lack of follow-up after admission.
- Balance course allocation among available instructors to prevent burnout.
- Ensure adequate resources (lecture halls, materials, instructors) for high-demand courses.
- Track student course load patterns to identify trends and improve curriculum planning.
- Strengthen academic advising to guide students in selecting the right number and type of courses.
  















  
