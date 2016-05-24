/* Find ID, name and GPA of students whose GPA is greater than 3.6 */
select sID, sName, GPA 
from Student
where GPA > 3.6;


/* Find names of the students and the majors for which they've applied */
select distinct sName, major
from Student, Apply
where Student.sID = Apply.sID;


/* Find names and GPAs of students whose size high school is less than 1000
and who have applied for CS at Stanford and the decision associated with that */
select sName, GPA, decision
from Student, Apply
where Student.sID = Apply.sID
and sizeHS < 1000 and major = 'CS' and cName = 'Stanford'; 


/* Find all large campuses (over 20k students) that have someone applying to
that campus in CS */
select College.cName
from College, Apply
where College.cName = Apply.cName
and enrollment > 20000 and major = 'CS';


/* Find the student ID, their name, their GPA, the college that they are
applying to and the enrollment of that college */
select distinct Student.sID, sName, GPA, Apply.cName, enrollment
from Student, Apply, College
where Student.sID = Apply.sID and College.cName = Apply.cName
order by GPA desc, enrollment;


/* Find the student IDs of those applying for anything to do with 'bio' fields */
select sID, major
from Apply
where major like '%bio%'


/* Display all info about a student and scale their GPA by sizeHS (in thousands)
then alias the new column as scaledGPA */ 
select sID, sName, sizeHS, GPA * (sizeHS/1000) as scaledGPA 
from Student;


/* Use table variables to make query output more readable */
select distinct S.sID, sName, GPA, A.cName, enrollment
from Student S, Apply A, College C
where S.sID = A.sID and C.cName = A.cName
order by GPA desc, enrollment;



/* Find all pairs of students who have the same GPA - 
Hint: you'll need the Student relation more than once so use
table variables to differentiate relations */
select S1.sID, S1.sName, S1.GPA, S2.sID, S2.sName, S2.GPA
from Student S1, Student S2 
where S1.GPA = S2.GPA and S1.sID < S2.sID;


/* Create a list of colleges and students 
Note: the UNION operator returns an unsorted result in PostgreSQL
but a sorted result in SQLite. Also note that it removes duplicates
by default (e.g note that Amy is not duplicated but theres two Amys) */
select cName from College
UNION
select sName from Student;


/* Create a list of colleges and students, sorted, with duplicates */
select sName as name from Student
UNION ALL
select cName as name from College
order by name;


/* Get the IDs of all students who have applied to both CS for a major and 
EE for a major */
select sID from Apply where major = 'CS'
INTERSECT
select sID from Apply where major = 'EE';


/* Get the IDs of all students who have applied to both CS and EE for a major
but don't use the INTERSECT operator */
select A1.sID
from Apply A1, Apply A2
where A1.sID = A2.sID and A1.major = 'EE' and A2.major = 'CS';


/* Find the students who applied to CS but not to EE */
select sID from Apply where major = 'CS'
EXCEPT
select sID from Apply where major = 'EE';


/* Find the IDs and names of students who have applied to major in CS at some college
Hint: use subqueries in the WHERE clause instead of using a join because you need to
be sure duplicates are distinct as duplicates do matter */
select sID, sName
from Student
where sID in (select sID from Apply where major = 'CS');


/* Find the students who applied to CS but not EE; however this time don't use
the difference (EXCEPT) operator, use the subqueries you just learnt */
select distinct sID 
from Apply
where sID in (select sID from Apply where major = 'CS')
and sID not in (select sID from Apply where major = 'EE');


/* Find all colleges such that there is some other college in the same state */
select C1.cName, C1.state
from College C1, College C2 
where C1.state = C2.state and C1.cName <> C2.cName; 


/* Find all colleges such that there is some other college in the same state
Hint: try using a subquery with the EXISTS operator to check for null results */
select cName, state
from College 
where exists (select * from College C2 where C2.state = C1.state and C1.cName <> c2.cName);


/* Find the student with the highest GPA
Note: you can later use the MAX function for this but try to compute it using concepts
learnt so far */
select sID, sName, GPA 
from Student S1
where not exists (select * from Student S2 where S1.GPA < S2.GPA);


/* Find the student with the highest GPA using the ALL keyword */
select sID, sName, GPA
from Student
where GPA >= ALL (select GPA from Student);


/* Find the unique college with the highest enrollment */
select cName
from College C1
where enrollment > ALL (select enrollment from College C2 where C2.cName <> C1.cName);


/* Find the unique college with the highest enrollment using the ANY keyword */
select cName
from College C1
where not enrollment <= any (select enrollment from College C2 where C2.cName <> C1.cName);


/* Find students not from the smallest school using the ANY keyword */
select sID, sName, sizeHS
from Student
where sizeHS > any (select sizeHS from Student);


/* Find students not from the smallest school */
select s1.sID, s1.sName, s1.sizeHS
from Student s1
where exists (select * from Student s2 where s2.sizeHS < s1.sizeHS);


/* Find the students who applied to CS but not EE using the ANY keyword */
select sID, sName
from Student
where sID = any (select sID from Apply where major = 'CS')
and not sID = any (select sID from Apply where major = 'EE');



/* Find students whose scaled GPA (by HS size) changes GPA by more than 1 */
select sID, sName, GPA, GPA*(sizeHS/1000.0) as scaledGPA
from Student
where abs(GPA*(sizeHS/1000.0) - GPA) > 1.0;


/* Find students whose scaled GPA (by HS size) changes GPA by more than 1 
Hint: use subqueries to make a table in the FROM clause first and select everything*/
select *
from (select sID, sName, GPA, GPA*(sizeHS/1000.0) as scaledGPA from Student) G
where abs(G.scaledGPA - GPA) > 1.0;


/* Display each college paired with the highest GPA of its applicants */
select distinct College.cName, state, GPA
from College, Apply, Student
where College.cName = Apply.cName
and Apply.sID = Student.sID
and GPA >= all (select GPA from Student, Apply
		where Student.sID = Apply.sID
		and Apply.cName = College.cName);
		

/* Display each college paired with the highest GPA of its applicants 
Hint: use a subquery in the SELECT clause that returns one value that can
then be taken and used as a column in the result tuple*/
select cName, state, 
(select distinct GPA
from Apply, Student
where College.cName = Apply.cName
and Apply.sID = Student.sID
and GPA >= all (select GPA from Student, Apply
		where Student.sID = Apply.sID
		and Apply.cName = College.cName)) as GPA
from College; 


/* Display all students paired with their majors */
select Student.sID, sName, major
from Student, Apply
where Student.sID = Apply.sID;


/* Display all students paired with their majors using INNER JOIN
which is the default join in SQL, so you could just write JOIN and
it would still be the same query */
select Student.sID, sName, major
from Student inner join Apply
on Student.sID = Apply.sID;


/* Find names and GPAs of students whose size high school is less than 1000
and who have applied for CS at Stanford using INNER JOIN. We've done this query
already without the join so it's a good example of how JOINs don't add any
expressive power */
select sName, GPA, decision
from Student join Apply
on Student.sID = Apply.sID
where sizeHS < 1000 and major = 'CS' and cName = 'Stanford'; 


/* Find the student ID, their name, their GPA, the college that they are
applying to and the enrollment of that college */
select distinct Student.sID, sName, GPA, Apply.cName, enrollment
from Student, Apply, College
where Student.sID = Apply.sID and College.cName = Apply.cName
order by GPA desc, enrollment;


/* Find the student ID, their name, their GPA, the college that they are
applying to and the enrollment of that college using JOIN */
select distinct Student.sID, sName, GPA, Apply.cName, enrollment
from (Student JOIN Apply ON Student.sID = Apply.sID) 
JOIN College ON College.cName = Apply.cName;


/* Display all students paired with their majors using NATURAL JOIN
which is a special kind of inner join which simply returns matched rowa,
even without any specific conditions. We've seen the query below with
an inner join already. Now we remove the condition and get same result*/
select Student.sID, sName, major
from Student NATURAL JOIN Apply;


/* Find names and GPAs of students whose size high school is less than 1000
and who have applied for CS at Stanford using an INNER JOIN with the 
USING(attrs) command. NOTE: not to be used with natural joins */
select sName, GPA, decision
from Student join Apply USING (sID)
where sizeHS < 1000 and major = 'CS' and cName = 'Stanford'; 


/* Return the students who have not applied anywhere
using a LEFT OUTER JOIN where all results from the left
table will be returned but non-matches from the table on
the right are padded with null values. Also known simply
as LEFT JOIN */
select sName, sID, cName, major
from Student left outer join Apply using(sID);


/* Return the students who have not applied anywhere
using a NATURAL LEFT OUTER JOIN where all results from the left
table will be returned but non-matches from the table on
the right are padded with null values. Also known simply
as NATURAL LEFT JOIN. Note:implicit matching. */
select sName, sID, cName, major
from Student natural left join Apply;


/* Return the students who have not applied anywhere
without using any explicit joins */
select sName, Student.sID, cName, major
from Student, Apply
where Student.sID = Apply.sID
UNION
select sName, sID, NULL, NULL
from Student
where sID not in (select sID from Apply);


/* Return name, college and major for students
 showing all NULL rows from both relations */
select sName, sID, cName, major
from Student FULL OUTER JOIN Apply using(sID);


/* Return name, college and major for students showing all NULL rows 
from both relations and without using the outer join*/
select sName, sID, cName, major
from Student LEFT OUTER JOIN Apply using(sID)
union
select sName, sID, cName, major
from Student RIGHT OUTER JOIN Apply using(sID);


/* Return name, college and major for students showing all NULL rows 
from both relations and without using any joins at all*/
select sName, Student.sID, cName, major
from Student, Apply
where Student.sID = Apply.sID
UNION
select sName, sID, NULL, NULL
from Student
where sID not in (select sID from Apply)
UNION
select NULL, sID, cName, major
from Apply
where sID not in (select sID from Student);


/* Compute the average GPA of all students */
select avg(GPA)
from Student;


/* Find the lowest GPA of students applying to CS */
select min(GPA)
from Student S, Apply A
where S.sID = A.sID and major = 'CS';


/* Find the average GPA of students applying to CS
Note: duplicate CS applications affect average so use
subquery to get distinct IDs first then aggregate */
select avg(GPA)
from Student
where sID in (select sID from Apply where major = 'CS');


/* Count the number of colleges in database */
select count(*)
from College;


/* Count number of students applying to Cornell
Hint: again, beware of duplicates */
select count(distinct sID)
from Apply
where cName = 'Cornell';


/* Return students for which the number of students with the
same GPA is equal to number of other students with same sizeHS */
select *
from Student S1
where (select count(*) from Student S2
	where S2.sID <> S1.sID and S2.GPA = S1.GPA) =
	(select count(*) from Student S2
	where S2.sID <> S1.sID and S2.sizeHS = S1.sizeHS);


/* Return amount by which average GPA of students applying to CS
exceeds average of students not applying to CS */
select (CS.avgGPA - NonCS.avgGPA) as GPADifference
from (select avg(GPA) as avgGPA from Student
	where sID in (select sID from Apply where major = 'CS')) as CS,
	(select avg(GPA) as avgGPA from Student
	where sID not in (select sID from Apply where major = 'CS')) as NonCS;

	
/* Return amount by which average GPA of students applying to CS
exceeds average of students not applying to CS with SELECT subquery */
select distinct ((select avg(GPA) as avgGPA from Student
	where sID in (select sID from Apply where major = 'CS')) -
	(select avg(GPA) as avgGPA from Student
	where sID not in (select sID from Apply where major = 'CS'))) as GPADifference
from Student;


/* Find number of applications to each college using the GROUP BY clause
which should only be used in conjunction with aggregation */
select cName, count(*)
from Apply
group by cName;


/* For each college and major combination, show the lowest and highest GPA
(GPA range) of applicants */
select cName, major, min(GPA), max(GPA)
from Apply A, Student S
where A.sID = S.sID
group by cName, major;


/* Find number of colleges applied to by each student  */
select Student.sID, count(distinct cName)
from Apply, Student
where Apply.sID = Student.sID
group by Student.sID;


/* Find number of colleges applied to by each student and
also show students who have not applied anywhere i.e. those
who are not included in the Apply table  */
select Student.sID, count(distinct cName)
from Apply, Student
where Apply.sID = Student.sID
group by Student.sID
UNION
select sID, 0
from Student
where sID not in (select sID from Apply);


/* Find colleges that have fewer than 5 applicants using the
HAVING clause which is also only used in conjunction with 
aggregation. It is assessed after grouping and allows us to
impose conditions on entire groups */
select cName
from Apply
group by cName
having count(*) < 5;


/* Find majors whose applicants' maximum GPA is below average GPA */
select major
from Apply, Student
where Apply.sID = Student.sID
group by major
having max(GPA) < (select avg(GPA) from Student);


/* Insert tuples one-by-one into a database */
Insert into Student values (432, 'Kevin', null, 1500);
Insert into Student values (321, 'Lori', null, 2500);


/* Return students whose GPA is either greater than 3.5 or
less than/equal to 3.5 - note that in theory all students should
be returned by this query. However, those with null GPAs are not! */
select sID, sName, GPA
from Student
where GPA > 3.5 or GPA <= 3.5;


/* Return students whose GPA is either greater than 3.5 or
less than/equal to 3.5 - note the explicit call for NULL values */
select sID, sName, GPA
from Student
where GPA > 3.5 or GPA <= 3.5 or GPA is NULL;


/* Modify database by adding Carnegie Mellon as a college */
INSERT INTO College VALUES ('Carnegie Mellon', 'PA', 11500);


/* Have all students who haven't applied anywhere apply to Carnegie Mellon */
insert into Apply
select sID, 'Carnegie Mellon', 'CS', null
from Student
where sID not in (select sID from Apply);


/* Have all students who have been turned down for EE elsewhere 
apply to Carnegie Mellon and get accepted straight away */
insert into Apply
select sID, 'Carnegie Mellon', 'EE', 'Y'
from Student
where sID in (select sID from Apply where major = 'EE' and decision='N');


/* Delete the naughty students who applied for more than one major */
DELETE FROM Student
WHERE sID in 
(select sID
from Apply
group by sID
having count (distinct major) > 2);


/* Delete the naughty students who applied for more than one major
Note - we now delete them from the Apply table */
DELETE FROM Apply
WHERE sID in 
(select sID
from Apply
group by sID
having count (distinct major) > 2);


/* Delete colleges with no CS applicants */
DELETE FROM College
WHERE cName not in (select cName from Apply where major = 'CS');


/* Find applicants to Carnegie Mellon with GPA < 3.6 and 
accept them only as economics majors */
UPDATE Apply
set decision = 'Y', major = 'economics'
where cname='Carnegie Mellon' 
and sid in (select sID from Student where GPA < 3.6);


/* Turn the highest-GPA EE applicant into a CSE applicant */
update Apply
set major = 'CSE'
where major = 'EE'
and sID in (select sID from Student 
	where GPA >= all (select GPA from Student
	where sID in (select sID from Apply where major = 'EE')));
	
	





