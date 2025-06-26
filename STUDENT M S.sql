CREATE TABLE Departments(
Department_id VARCHAR(10) PRIMARY KEY NOT NULL,
Department_name VARCHAR(30)
);


CREATE TABLE Courses(
Course_id VARCHAR(10) PRIMARY KEY NOT NULL,
Course_name VARCHAR(25),
Department_id VARCHAR(10) REFERENCES Departments(Department_id),
Instructor_id INT REFERENCES Instructors(Instructor_id)
);

CREATE TABLE Instructors(
Instructor_id INT PRIMARY KEY NOT NULL,
First_name VARCHAR(20),
Last_name VARCHAR(20),
Email VARCHAR(50)
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




SELECT *
FROM Students

--Student & Enrollment Reports
--How many students are currently enrolled in each course?
SELECT C.Course_name,
		COUNT(E.Enrollment_id) total_enrollment
FROM Students S 
JOIN Enrollments E ON S.Student_id = E.Student_id
JOIN Courses C ON C.course_id = E.Course_id
GROUP BY Course_name
ORDER BY total_enrollment DESC;

--Which students are enrolled in multiple courses, and which courses are they taking?
WITH multiple_course AS(
SELECT E.Student_id,
		COUNT(E.Course_id) AS no_of_courses
FROM Enrollments E
GROUP BY E.Student_id
HAVING COUNT(E.Course_id) > 1
)

SELECT S.Student_id,
        S.First_name,
		S.last_name,
		C.Course_name
FROM multiple_course M
JOIN Students S ON S.Student_id = M.Student_id
JOIN Enrollments E ON S.Student_id = E.Student_id
JOIN Courses C  ON C.Course_id = E.Course_id
ORDER BY S.Student_id, C.Course_name DESC;


--What is the total number of students per department across all courses?
SELECT D.Department_name,
		COUNT(S.Student_id) total_students
FROM Students S
JOIN Departments D ON S.Department_id = D.Department_id
GROUP BY D.Department_name
ORDER BY total_students DESC;

--Course & Instructor Analysis
--Which courses have the highest number of enrollments?
SELECT C.Course_name,
		COUNT(E.Enrollment_id) AS total_enrollments
FROM Courses C
JOIN Enrollments E ON C.Course_id = E.Course_id
GROUP BY C.Course_name
ORDER BY total_enrollments DESC
LIMIT 4;

--Which department has the least number of students?
SELECT D.Department_name,
		COUNT(S.Student_id) AS total_students
FROM Departments D
JOIN Students S ON D.Department_id = S.Department_id
GROUP BY D.Department_name
ORDER BY total_students
LIMIT 1;

--Data Integrity & Operational Insights

--Are there any students not enrolled in any course?
SELECT S.Student_id,
		CONCAT(S.First_name,' ', S.Last_name) AS Full_name,
		E.Enrollment_id,
		C.Course_name
FROM STUDENTS S
LEFT JOIN Enrollments E ON S.Student_id = E.Student_id
LEFT JOIN Courses C ON C.Course_id = E.Course_id
WHERE E.Enrollment_id IS NULL;



--How many courses does each student take on average?

WITH course_counts AS (
  SELECT 
    E.Student_id, 
    COUNT(E.Course_id) AS courses_taken
  FROM Enrollments E
  GROUP BY E.Student_id
)
SELECT ROUND(AVG(courses_taken)) AS avg_courses_per_student
FROM course_counts;

--What is the gender distribution of students across courses and instructors?
SELECT C.Course_name,
		CONCAT(I.First_name, ' ', I.Last_name) AS Instructors,
		S.Gender,
		COUNT(S.Gender) AS total
FROM Students S
JOIN Enrollments E ON S.Student_id = E.Student_id
JOIN Courses C  ON C.Course_id = E.Course_id
JOIN Instructors I ON C.Instructor_id = I.Instructor_id
GROUP BY C.Course_name, S.Gender, Instructors



--Which course has the highest number of male or female students enrolled?
WITH course_per_gender AS(
SELECT Gender, course_name,
		COUNT(E.enrollment_id) AS total_enrollments,
		ROW_NUMBER() OVER(PARTITION BY S.Gender ORDER BY COUNT(E.enrollment_id)DESC) AS Gender_rank
FROM Students S
    JOIN 
        Enrollments E ON S.Student_id = E.Student_id
    JOIN 
        Courses C ON C.Course_id = E.Course_id
    GROUP BY 
        C.Course_name, S.Gender
)

SELECT Gender, 
		course_name,
		total_enrollments
FROM course_per_gender
WHERE Gender_rank = 1;


