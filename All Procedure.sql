USE StudentManagementSystem
GO
IF EXISTS(SELECT name FROM sysobjects
WHERE name='registedCoursesProc' AND type='P')
DROP PROCEDURE registedCoursesProc
GO
CREATE PROCEDURE registedCoursesProc
@inputId varchar(10)
AS
select sc.subject_id, grade_point, subject_credit from 
register_and_learn rl join subject_class sc on rl.subject_class_id = sc.subject_class_id
join subject_list sl on sl.subject_id = sc.subject_id 
where student_id = @inputId
group by sc.subject_id, grade_point, subject_credit

declare @inputId varchar(10)
exec registedCoursesProc @inputId = '20194251'
------------------------------------------------------------------------------------------------------------------------------
--get scoreSheet
USE StudentManagementSystem
GO
IF EXISTS(SELECT name FROM sysobjects
WHERE name='scoreSheetProc' AND type='P')
DROP PROCEDURE scoreSheetProc
GO
CREATE PROCEDURE scoreSheetProc
@inputId varchar(10)
AS
select rl.subject_class_id, sl.subject_name, midterm_score, final_score, overall, grade
from register_and_learn rl join subject_class sc on (rl.subject_class_id = sc.subject_class_id and rl.semester = sc.semester)
join subject_list sl on sl.subject_id = sc.subject_id
where student_id = @inputId
group by rl.subject_class_id, sl.subject_name, midterm_score, final_score, overall, grade

declare @inputId varchar(10)
exec scoreSheetProc @inputId = '20190007'
------------------------------------------------------------------------------------------------------------------------------
--GET schedule
use StudentManagementSystem
go
if exists(select name from sysobjects where name = 'schedule_proc' and type = 'P')
drop proc schedule_proc
go 
create proc schedule_proc 
@student_id varchar(10),
@semester varchar(10)
as
select rl.semester, rl.student_id, rl.subject_class_id, sc.subject_id, sl.subject_name, week, day, start_time, end_time, room
from register_and_learn rl join subject_class sc on rl.subject_class_id = sc.subject_class_id
join subject_list sl on sl.subject_id = sc.subject_id
where rl.student_id = @student_id and rl.semester = @semester
group by rl.semester, rl.student_id, rl.subject_class_id, sc.subject_id, sl.subject_name, week, day, start_time, end_time, room


declare @student_id varchar(10), @semester varchar(10)
exec schedule_proc @student_id = '20190007', @semester = '20191'

------------------------------------------------------------------------------------------------------------------------------
use StudentManagementSystem
go
if exists(select name from sysobjects where name = 'get_semester_proc' and type = 'P')
drop proc get_semester_proc
go 
create proc get_semester_proc
@student_id varchar(10)
as 
select distinct semester from register_and_learn where student_id = @student_id

declare @student_id varchar(10)
exec get_semester_proc @student_id = '20190007'

------------------------------------------------------------------------------------------------------------------------------
--update score
USE StudentManagementSystem
GO
IF EXISTS(SELECT name FROM sysobjects
WHERE name='update1' AND type='P')
DROP proc update1
GO
CREATE proc update1
@std varchar(10), @sbc varchar(10)
AS
update register_and_learn
set overall = midterm_score*(1-final_weight) + final_score*final_weight
from subject_class sc, subject_list sl
where register_and_learn .subject_class_id = sc.subject_class_id
and register_and_learn.semester = sc.semester
and sc.subject_id = sl.subject_id
and register_and_learn.student_id = @std
and register_and_learn.subject_class_id = @sbc;

------------------------------------------------------------------------------------------------------------------------------
USE StudentManagementSystem
GO
IF EXISTS(SELECT name FROM sysobjects
WHERE name='update2' AND type='P')
DROP proc update2
GO
CREATE proc update2 
@std varchar(10), @sbc varchar(10)
AS
update register_and_learn
set grade = case
		when overall < 4 then 'F'
		when overall < 5 then 'D'
		when overall < 5.5 then 'D+'
		when overall < 6.5 then 'C'
		when overall < 7 then 'C+'
		when overall < 8 then 'B'
		when overall < 8.5 then 'B+'
		when overall < 9.5 then 'A'
		when overall <= 10 then 'A+'
end
where student_id = @std
and subject_class_id = @sbc;
------------------------------------------------------------------------------------------------------------------------------
USE StudentManagementSystem
GO
IF EXISTS(SELECT name FROM sysobjects
WHERE name='update3' AND type='P')
DROP proc update3
GO
CREATE proc update3 
@std varchar(10), @sbc varchar(10)
AS
update register_and_learn
set	grade_point = case grade
		when 'F' then 0
		when 'D' then 1
		when 'D+' then 1.5
		when 'C' then 2
		when 'C+' then 2.5
		when 'B' then 3
		when 'B+' then 3.5
		when 'A' then 4
		when 'A+' then 4

end
where student_id = @std
and subject_class_id = @sbc;

UPDATE register_and_learn
SET midterm_score = 10, final_score = 4
WHERE subject_class_id = '100101' and student_id = '20190007';

declare @std varchar(10), @sbc varchar(10)
exec update1 @std = '20190007', @sbc = '100101';
exec update2 @std = '20190007', @sbc = '100101';
exec update3 @std = '20190007', @sbc = '100101';








