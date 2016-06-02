/* ************************ SCHEMA ************************************** */

INSERT INTO Student VALUES (123, 'Amy', 3.9, 1000);
INSERT INTO Student VALUES (234, 'Bob', 3.6, 1500);
INSERT INTO Student VALUES (345, 'Craig', 3.5, 500);
INSERT INTO Student VALUES (456, 'Doris', 3.9, 1000);
INSERT INTO Student VALUES (567, 'Edward', 2.9, 2000);
INSERT INTO Student VALUES (678, 'Fay', 3.8, 200);
INSERT INTO Student VALUES (789, 'Gary', 3.4, 800);
INSERT INTO Student VALUES (987, 'Helen', 3.7, 800);
INSERT INTO Student VALUES (876, 'Irene', 3.9, 400);
INSERT INTO Student VALUES (765, 'Jay', 2.9, 1500);
INSERT INTO Student VALUES (654, 'Amy', 3.9, 1000);
INSERT INTO Student VALUES (543, 'Craig', 3.4, 2000);

INSERT INTO College VALUES ('Stanford', 'CA', 15000);
INSERT INTO College VALUES ('Berkeley', 'CA', 36000);
INSERT INTO College VALUES ('MIT', 'MA', 10000);
INSERT INTO College VALUES ('Cornell', 'NY', 21000);

INSERT INTO Apply VALUES (123, 'Stanford', 'CS', 'Y');
INSERT INTO Apply VALUES (123, 'Stanford', 'EE', 'N');
INSERT INTO Apply VALUES (123, 'Berkeley', 'CS', 'Y');
INSERT INTO Apply VALUES (123, 'Cornell', 'EE', 'Y');
INSERT INTO Apply VALUES (234, 'Berkeley', 'biology', 'N');
INSERT INTO Apply VALUES (345, 'MIT', 'bioengineering', 'Y');
INSERT INTO Apply VALUES (345, 'Cornell', 'bioengineering', 'N');
INSERT INTO Apply VALUES (345, 'Cornell', 'CS', 'Y');
INSERT INTO Apply VALUES (345, 'Cornell', 'EE', 'N');
INSERT INTO Apply VALUES (678, 'Stanford', 'history', 'Y');
INSERT INTO Apply VALUES (987, 'Stanford', 'CS', 'Y');
INSERT INTO Apply VALUES (987, 'Berkeley', 'CS', 'Y');
INSERT INTO Apply VALUES (876, 'Stanford', 'CS', 'N');
INSERT INTO Apply VALUES (876, 'MIT', 'biology', 'Y');
INSERT INTO Apply VALUES (876, 'MIT', 'marine biology', 'N');
INSERT INTO Apply VALUES (765, 'Stanford', 'history', 'Y');
INSERT INTO Apply VALUES (765, 'Cornell', 'history', 'N');
INSERT INTO Apply VALUES (765, 'Cornell', 'psychology', 'Y');
INSERT INTO Apply VALUES (543, 'MIT', 'CS', 'N');

CREATE TABLE College(cName TEXT, state TEXT, enrollment INT);
CREATE TABLE Student(sID INT, sName TEXT, GPA REAL, sizeHS INT);
CREATE TABLE Apply(sID INT, cName TEXT, major TEXT, decision TEXT);

/* ************************ SCHEMA ENDS HERE ************************************** */

/* Find ID, name and GPA of students whose GPA is greater than 3.6 */
SELECT sID, sName, GPA 
FROM Student
WHERE GPA > 3.6;


/* Find names of the students and the majors for which they've applied */
SELECT DISTINCT sName, major
FROM Student, Apply
WHERE Student.sID = Apply.sID;


/* Find names and GPAs of students whose size high school is less than 1000
and who have applied for CS at Stanford and the decision associated with that */
SELECT sName, GPA, decision
FROM Student, Apply
WHERE Student.sID = Apply.sID
AND sizeHS < 1000 AND major = 'CS' AND cName = 'Stanford'; 


/* Find all large campuses (over 20k students) that have someone applying to
that campus in CS */
SELECT College.cName
FROM College, Apply
WHERE College.cName = Apply.cName
AND enrollment > 20000 AND major = 'CS';


/* Find the student ID, their name, their GPA, the college that they are
applying to and the enrollment of that college */
SELECT DISTINCT Student.sID, sName, GPA, Apply.cName, enrollment
FROM Student, Apply, College
WHERE Student.sID = Apply.sID AND College.cName = Apply.cName
ORDER BY GPA DESC, enrollment;


/* Find the student IDs of those applying for anything to do with 'bio' fields */
SELECT sID, major
FROM Apply
WHERE major LIKE '%bio%'


/* Display all info about a student and scale their GPA by sizeHS (in thousands)
then alias the new column as scaledGPA */ 
SELECT sID, sName, sizeHS, GPA * (sizeHS/1000) AS scaledGPA 
FROM Student;


/* Use table variables to make query output more readable */
SELECT DISTINCT S.sID, sName, GPA, A.cName, enrollment
FROM Student S, Apply A, College C
WHERE S.sID = A.sID AND C.cName = A.cName
ORDER BY GPA DESC, enrollment;



/* Find all pairs of students who have the same GPA - 
Hint: you'll need the Student relation more than once so use
table variables to differentiate relations */
SELECT S1.sID, S1.sName, S1.GPA, S2.sID, S2.sName, S2.GPA
FROM Student S1, Student S2 
WHERE S1.GPA = S2.GPA AND S1.sID < S2.sID;


/* Create a list of colleges AND students 
Note: the UNION operator returns an unsorted result in PostgreSQL
but a sorted result in SQLite. Also note that it removes duplicates
by default (e.g note that Amy is not duplicated but there's two Amys) */
SELECT cName FROM College
UNION
SELECT sName FROM Student;


/* Create a list of colleges and students, sorted, with duplicates */
SELECT sName as name FROM Student
UNION ALL
SELECT cName as name FROM College
ORDER BY name;


/* Get the IDs of all students who have applied to both CS for a major and 
EE for a major */
SELECT sID FROM Apply WHERE major = 'CS'
INTERSECT
SELECT sID FROM Apply WHERE major = 'EE';


/* Get the IDs of all students who have applied to both CS and EE for a major
but don't use the INTERSECT operator */
SELECT A1.sID
FROM Apply A1, Apply A2
WHERE A1.sID = A2.sID AND A1.major = 'EE' AND A2.major = 'CS';


/* Find the students who applied to CS but not to EE */
SELECT sID FROM Apply WHERE major = 'CS'
EXCEPT
SELECT sID FROM Apply WHERE major = 'EE';


/* Find the IDs and names of students who have applied to major in CS at some college
Hint: best method is to use subqueries in the WHERE clause instead of using a join because 
you need to be sure duplicates are DISTINCT as duplicates do matter */
SELECT sID, sName
FROM Student
WHERE sID IN (SELECT sID FROM Apply WHERE major = 'CS');


/* Find the students who applied to CS but not EE; however this time don't use
the difference (EXCEPT) operator, use the subqueries you just learnt */
SELECT DISTINCT sID 
FROM Apply
WHERE sID IN (SELECT sID FROM Apply WHERE major = 'CS')
AND sID NOT IN (SELECT sID FROM Apply WHERE major = 'EE');


/* Find all colleges such that there is some other college in the same state */
SELECT C1.cName, C1.state
FROM College C1, College C2 
WHERE C1.state = C2.state AND C1.cName <> C2.cName; 


/* Find all colleges such that there is some other college in the same state
Hint: try using a subquery with the EXISTS operator to check for null results */
SELECT cName, state
FROM College 
WHERE EXISTS (SELECT * FROM College C2 WHERE C2.state = C1.state AND C1.cName <> c2.cName);


/* Find the student with the highest GPA
Note: you can later use the MAX function for this but try to compute it using concepts
learnt so far */
SELECT sID, sName, GPA 
FROM Student S1
WHERE NOT EXISTS (SELECT * FROM Student S2 WHERE S1.GPA < S2.GPA);


/* Find the student with the highest GPA using the ALL keyword */
SELECT sID, sName, GPA
FROM Student
WHERE GPA >= ALL (SELECT GPA FROM Student);


/* Find the unique college with the highest enrollment */
SELECT cName
FROM College C1
WHERE enrollment > ALL (SELECT enrollment FROM College C2 WHERE C2.cName <> C1.cName);


/* Find the unique college with the highest enrollment using the ANY keyword */
SELECT cName
FROM College C1
WHERE NOT enrollment <= ANY (SELECT enrollment FROM College C2 WHERE C2.cName <> C1.cName);


/* Find students not from the smallest school using the ANY keyword */
SELECT sID, sName, sizeHS
FROM Student
WHERE sizeHS > ANY (SELECT sizeHS FROM Student);


/* Find students not FROM the smallest school */
SELECT s1.sID, s1.sName, s1.sizeHS
FROM Student s1
WHERE EXISTS (SELECT * FROM Student s2 WHERE s2.sizeHS < s1.sizeHS);


/* Find the students who applied to CS but not EE using the ANY keyword */
SELECT sID, sName
FROM Student
WHERE sID = ANY (SELECT sID FROM Apply WHERE major = 'CS')
AND NOT sID = ANY (SELECT sID FROM Apply WHERE major = 'EE');



/* Find students whose scaled GPA (by HS size) changes GPA by more than 1 */
SELECT sID, sName, GPA, GPA*(sizeHS/1000.0) as scaledGPA
FROM Student
WHERE abs(GPA*(sizeHS/1000.0) - GPA) > 1.0;


/* Find students whose scaled GPA (by HS size) changes GPA by more than 1 
Hint: use subqueries to make a table in the FROM clause first and select all attributes*/
SELECT *
FROM (SELECT sID, sName, GPA, GPA*(sizeHS/1000.0) AS scaledGPA FROM Student) G
WHERE abs(G.scaledGPA - GPA) > 1.0;


/* Display each college paired with the highest GPA of its applicants */
SELECT DISTINCT College.cName, state, GPA
FROM College, Apply, Student
WHERE College.cName = Apply.cName
AND Apply.sID = Student.sID
AND GPA >= ALL (SELECT GPA FROM Student, Apply
		WHERE Student.sID = Apply.sID
		AND Apply.cName = College.cName);
		

/* Display each college paired with the highest GPA of its applicants 
Hint: use a subquery in the SELECT clause that returns one value that can
then be taken and used as a column in the result tuple*/
SELECT cName, state, 
(SELECT DISTINCT GPA
FROM Apply, Student
WHERE College.cName = Apply.cName
AND Apply.sID = Student.sID
AND GPA >= ALL (SELECT GPA FROM Student, Apply
		WHERE Student.sID = Apply.sID
		AND Apply.cName = College.cName)) AS GPA
FROM College; 


/* Display all students paired with their majors */
SELECT Student.sID, sName, major
FROM Student, Apply
WHERE Student.sID = Apply.sID;


/* Display all students paired with their majors using INNER JOIN
which is the default join in SQL, so you could just write a JOIN and
it would still be the same query */
SELECT Student.sID, sName, major
FROM Student INNER JOIN Apply
ON Student.sID = Apply.sID;


/* Find names and GPAs of students whose size high school is less than 1000
and who have applied for CS at Stanford using INNER JOIN. We've done this query
already without the join so it's a good example to show how JOINs don't add any
expressive power */
SELECT sName, GPA, decision
FROM Student JOIN Apply
ON Student.sID = Apply.sID
WHERE sizeHS < 1000 AND major = 'CS' AND cName = 'Stanford'; 


/* Find the student ID, their name, their GPA, the college that they are
applying to and the enrollment of that college */
SELECT DISTINCT Student.sID, sName, GPA, Apply.cName, enrollment
FROM Student, Apply, College
WHERE Student.sID = Apply.sID AND College.cName = Apply.cName
ORDER BY GPA DESC, enrollment;


/* Find the student ID, their name, their GPA, the college that they are
applying to and the enrollment of that college using JOIN */
SELECT DISTINCT Student.sID, sName, GPA, Apply.cName, enrollment
FROM (Student JOIN Apply ON Student.sID = Apply.sID) 
JOIN College ON College.cName = Apply.cName;


/* Display all students paired with their majors using NATURAL JOIN
which is a special kind of inner join which simply returns matched rowa,
even without any specific conditions. We've seen the query below with
an inner join already. Now we remove the condition AND get same result*/
SELECT Student.sID, sName, major
FROM Student NATURAL JOIN Apply;


/* Find names and GPAs of students whose size high school is less than 1000
and who have applied for CS at Stanford using an INNER JOIN with the 
USING(attrs) command. NOTE: not to be used with NATURAL JOINs */
SELECT sName, GPA, decision
FROM Student JOIN Apply USING (sID)
WHERE sizeHS < 1000 AND major = 'CS' AND cName = 'Stanford'; 


/* Return the students who have not applied anywhere
using a LEFT OUTER JOIN WHERE all results from the left
table will be returned but non-matches from the table on
the right are padded with null values. Also known simply
as LEFT JOIN */
SELECT sName, sID, cName, major
FROM Student LEFT OUTER JOIN Apply USING(sID);


/* Return the students who have not applied anywhere 
using a NATURAL LEFT OUTER JOIN where all results from the left
table will be returned but non-matches from the table on
the right are padded with null values. Also known simply
as NATURAL LEFT JOIN. Note:implicit matching. */
SELECT sName, sID, cName, major
FROM Student NATURAL LEFT OUTER JOIN Apply;


/* Return the students who have not applied anywhere
without using any explicit joins */
SELECT sName, Student.sID, cName, major
FROM Student, Apply
WHERE Student.sID = Apply.sID
UNION
SELECT sName, sID, NULL, NULL
FROM Student
WHERE sID NOT IN (SELECT sID FROM Apply);


/* Return name, college and major for students
 showing all null rows from both relations */
SELECT sName, sID, cName, major
FROM Student FULL OUTER JOIN Apply USING(sID);


/* Return name, college and major for students showing all null rows 
from both relations and without using the outer join*/
SELECT sName, sID, cName, major
FROM Student LEFT OUTER JOIN Apply USING(sID)
UNION
SELECT sName, sID, cName, major
FROM Student RIGHT OUTER JOIN Apply USING(sID);


/* Return name, college and major for students showing all null rows 
from both relations and without using any joins at all*/
SELECT sName, Student.sID, cName, major
FROM Student, Apply
WHERE Student.sID = Apply.sID
UNION
SELECT sName, sID, NULL, NULL
FROM Student
WHERE sID NOT IN (SELECT sID FROM Apply)
UNION
SELECT NULL, sID, cName, major
FROM Apply
WHERE sID NOT IN (SELECT sID FROM Student);


/* Compute the average GPA of all students */
SELECT AVG(GPA)
FROM Student;


/* Find the lowest GPA of students applying to CS */
SELECT MIN(GPA)
FROM Student S, Apply A
WHERE S.sID = A.sID AND major = 'CS';


/* Find the average GPA of students applying to CS
Note: duplicate CS applications affect average so use
subquery to get distinct IDs first then aggregate */
SELECT AVG(GPA)
FROM Student
WHERE sID IN (SELECT sID FROM Apply WHERE major = 'CS');


/* Count the number of colleges in database */
SELECT COUNT(*)
FROM College;


/* Count number of students applying to Cornell
Hint: again, beware of duplicates */
SELECT COUNT(DISTINCT sID)
FROM Apply
WHERE cName = 'Cornell';


/* Return students for which the number of students with the
same GPA is equal to number of other students with same sizeHS */
SELECT *
FROM Student S1
WHERE (SELECT COUNT(*) FROM Student S2
	WHERE S2.sID <> S1.sID AND S2.GPA = S1.GPA) =
	(SELECT count(*) FROM Student S2
	WHERE S2.sID <> S1.sID AND S2.sizeHS = S1.sizeHS);


/* Return amount by which average GPA of students applying to CS
exceeds average of students not applying to CS */
SELECT (CS.avgGPA - NonCS.avgGPA) AS GPADifference
FROM (SELECT AVG(GPA) AS avgGPA FROM Student
	WHERE sID IN (SELECT sID FROM Apply WHERE major = 'CS')) AS CS,
	(SELECT AVG(GPA) AS avgGPA FROM Student
	WHERE sID NOT IN (SELECT sID FROM Apply WHERE major = 'CS')) AS NonCS;

	
/* Return amount by which average GPA of students applying to CS
exceeds average of students not applying to CS with SELECT subquery */
SELECT DISTINCT ((SELECT AVG(GPA) as avgGPA FROM Student
	WHERE sID IN (SELECT sID FROM Apply WHERE major = 'CS')) -
	(SELECT AVG(GPA) as avgGPA FROM Student
	WHERE sID NOT IN (SELECT sID FROM Apply WHERE major = 'CS'))) AS GPADifference
FROM Student;


/* Find number of applications to each college using the GROUP BY clause
which should only be used in conjunction with aggregation */
SELECT cName, COUNT(*)
FROM Apply
GROUP BY cName;


/* For each college and major combination, show the lowest and highest GPA
(GPA range) of applicants */
SELECT cName, major, MIN(GPA), MAX(GPA)
FROM Apply A, Student S
WHERE A.sID = S.sID
GROUP BY cName, major;


/* Find number of colleges applied to by each student  */
SELECT Student.sID, COUNT(DISTINCT cName)
FROM Apply, Student
WHERE Apply.sID = Student.sID
GROUP BY Student.sID;


/* Find number of colleges applied to by each student and
also show students who have not applied anywhere i.e. those
who are not included in the Apply table  */
SELECT Student.sID, COUNT(DISTINCT cName)
FROM Apply, Student
WHERE Apply.sID = Student.sID
GROUP BY Student.sID
UNION
SELECT sID, 0
FROM Student
WHERE sID NOT IN (SELECT sID FROM Apply);


/* Find colleges that have fewer than 5 applicants using the
HAVING clause which is also only used in conjunction with 
aggregation. It is assessed after grouping and it allows us to
impose conditions on entire groups */
SELECT cName
FROM Apply
GROUP BY cName
HAVING COUNT(*) < 5;


/* Find majors whose applicants' maximum GPA is below average GPA */
SELECT major
FROM Apply, Student
WHERE Apply.sID = Student.sID
GROUP BY major
HAVING MAX(GPA) < (SELECT AVG(GPA) FROM Student);


/* Insert tuples one-by-one into a database */
INSERT INTO Student VALUES (432, 'Kevin', NULL, 1500);
INSERT INTO Student VALUES (321, 'Lori', NULL, 2500);


/* Return students whose GPA is either greater than 3.5 or
less than or equal to 3.5 - note that in theory all students should
be returned by this query. However, those with null GPAs are not! */
SELECT sID, sName, GPA
FROM Student
WHERE GPA > 3.5 OR GPA <= 3.5;


/* Return students whose GPA is either greater than 3.5 or
less than/equal to 3.5 - note the explicit call for null values */
SELECT sID, sName, GPA
FROM Student
WHERE GPA > 3.5 OR GPA <= 3.5 OR GPA IS NULL;


/* Modify database by adding Carnegie Mellon as a college */
INSERT INTO College VALUES ('Carnegie Mellon', 'PA', 11500);


/* Have all students who haven't applied anywhere apply to Carnegie Mellon */
INSERT INTO Apply
SELECT sID, 'Carnegie Mellon', 'CS', NULL
FROM Student
WHERE sID NOT IN (SELECT sID FROM Apply);


/* Have all students who have been turned down for EE elsewhere 
apply to Carnegie Mellon and get accepted straight away */
INSERT INTO Apply
SELECT sID, 'Carnegie Mellon', 'EE', 'Y'
FROM Student
WHERE sID IN (SELECT sID FROM Apply WHERE major = 'EE' AND decision='N');


/* Delete the naughty students who applied for more than one major */
DELETE FROM Student
WHERE sID IN 
(SELECT sID
FROM Apply
GROUP BY sID
HAVING COUNT(DISTINCT major) > 2);


/* Delete the naughty students who applied for more than one major
Note - we now delete them from the Apply table */
DELETE FROM Apply
WHERE sID IN 
(SELECT sID
FROM Apply
GROUP BY sID
HAVING COUNT(DISTINCT major) > 2);


/* Delete colleges with no CS applicants */
DELETE FROM College
WHERE cName NOT IN (SELECT cName FROM Apply WHERE major = 'CS');


/* Find applicants to Carnegie Mellon with GPA < 3.6 and 
accept them only as economics majors */
UPDATE Apply
SET decision = 'Y', major = 'economics'
WHERE cname='Carnegie Mellon' 
AND sID IN (SELECT sID FROM Student WHERE GPA < 3.6);


/* Turn the highest-GPA EE applicant into a CSE applicant */
UPDATE Apply
SET major = 'CSE'
WHERE major = 'EE'
AND sID IN (SELECT sID FROM Student 
	WHERE GPA >= ALL (SELECT GPA FROM Student
	WHERE sID IN (SELECT sID FROM Apply WHERE major = 'EE')));
	
	





