#Read the table
SELECT COUNT(Gender)
FROM port_osteo.osteoporosis;

#Check empty data
SELECT *
FROM port_osteo.osteoporosis
WHERE Alcohol_Consumption is null;


#Chech duplicate Id
SELECT Id, COUNT(Id)
FROM
    port_osteo.osteoporosis
GROUP BY Id
HAVING COUNT(Id) > 1;

#Make sure that some duplicate Ids have same value in each column
SELECT Id, Age, Gender, Hormonal_Changes, Race_or_Ethnicity, COUNT(Id)
FROM port_osteo.osteoporosis
GROUP BY Id, Age, Gender, Hormonal_Changes, Race_or_Ethnicity
HAVING COUNT(Id) > 1;

#Because there is no duplicate, we continue with the next step
#Checking every column's values
SHOW COLUMNS FROM port_osteo.osteoporosis;
SELECT DISTINCT min(Age),max(Age)
FROM port_osteo.osteoporosis;
SELECT DISTINCT Gender
FROM port_osteo.osteoporosis;
SELECT DISTINCT Hormonal_Changes
FROM port_osteo.osteoporosis;
SELECT DISTINCT Family_History
FROM port_osteo.osteoporosis;
SELECT DISTINCT Race_or_Ethnicity
FROM port_osteo.osteoporosis;
SELECT DISTINCT Body_Weight
FROM port_osteo.osteoporosis;
SELECT DISTINCT Calcium_Intake
FROM port_osteo.osteoporosis;
SELECT DISTINCT Vitamin_D_Intake
FROM port_osteo.osteoporosis;
SELECT DISTINCT Physical_Activity
FROM port_osteo.osteoporosis;
SELECT DISTINCT Smoking
FROM port_osteo.osteoporosis;
SELECT DISTINCT Alcohol_Consumption
FROM port_osteo.osteoporosis;
SELECT DISTINCT Medical_Conditions
FROM port_osteo.osteoporosis;
SELECT DISTINCT Medications
FROM port_osteo.osteoporosis;
SELECT DISTINCT Prior_Fractures
FROM port_osteo.osteoporosis;
SELECT DISTINCT Osteoporosis
FROM port_osteo.osteoporosis;


#Masking the Id to keep the respondent's privacy
SELECT min(length(Id))
FROM port_osteo.osteoporosis;

SELECT COUNT(Gender)
FROM port_osteo.osteoporosis;

CREATE TABLE port_osteo.masking(Id int, mask_ text);
SELECT COUNT(Id)
FROM port_osteo.masking;
INSERT INTO port_osteo.masking
Select Id,
Replace(Id, substring(Id,2,4),'XXXX') as mask_
FROM port_osteo.osteoporosis;
SELECT *
FROM port_osteo.masking;
SELECT *
FROM port_osteo.osteoporosis;

#Check join
SELECT *
FROM port_osteo.masking as a
RIGHT JOIN port_osteo.osteoporosis as b
ON a.Id=b.Id;

#Create a new column in the first table
ALTER TABLE port_osteo.osteoporosis
ADD mask_ text;

#Update the first table with a masking id
SET SQL_SAFE_UPDATES=0;
UPDATE port_osteo.osteoporosis as a inner join port_osteo.masking as b ON a.Id=b.Id
SET a.mask_=b.mask_;

#Change typedata Id from int to text
ALTER TABLE port_osteo.osteoporosis MODIFY Id text;
#Change the value in Id to mask_ so the Id will be masking
UPDATE port_osteo.osteoporosis 
SET Id=mask_;
#Delete mask_ column
ALTER TABLE port_osteo.osteoporosis
DROP mask_;

#NOW TABLE LOOKS BETTER

#Find out about people who get osteoporosis and their family_history
SELECT Race_or_Ethnicity, Family_History, Gender, Count(Id) as num_of_people
FROM port_osteo.osteoporosis
WHERE Osteoporosis=1
GROUP BY Gender, Race_or_Ethnicity, Family_History
ORDER BY Race_or_Ethnicity, Gender DESC, Family_History DESC

#Find out about people who don't get osteoporosis and their family_history
SELECT Race_or_Ethnicity, Family_History, Gender, Count(Id) as num_of_people
FROM port_osteo.osteoporosis
WHERE Osteoporosis=0
GROUP BY Gender, Race_or_Ethnicity, Family_History
ORDER BY Race_or_Ethnicity, Gender DESC, Family_History DESC

#Effects of Hormonal Changes on People's Osteoporosis
SELECT Hormonal_Changes,  Gender, count(Hormonal_Changes) as num_of_people
FROM port_osteo.osteoporosis
WHERE Osteoporosis=1
GROUP BY Hormonal_Changes, Gender
ORDER BY Hormonal_Changes

#Smoking and alcohol consumption effect on Osteoporosis
SELECT Smoking,  Alcohol_Consumption, count(Alcohol_Consumption) as num_people
FROM port_osteo.osteoporosis
WHERE Osteoporosis=1
GROUP BY Smoking, Alcohol_Consumption
ORDER BY Smoking DESC

#People with prior fractures have osteoporosis?
SELECT Prior_Fractures,  Osteoporosis, Count(Prior_Fractures) as num_of_people
FROM port_osteo.osteoporosis
GROUP BY Prior_Fractures, Osteoporosis

#Effects of Prior Fractures, Smoking, and Alcohol Consumption on Osteoporosis
SELECT Osteoporosis, Prior_Fractures, Smoking,  Alcohol_Consumption, count(Alcohol_Consumption) as num_people
FROM port_osteo.osteoporosis
GROUP BY Prior_Fractures, Osteoporosis,Smoking, Alcohol_Consumption
ORDER BY Osteoporosis DESC, Prior_Fractures


#Distribution of age to those who got Osteoporosis
SELECT Age, count(Age) as num_age
FROM port_osteo.osteoporosis
WHERE Osteoporosis=1
GROUP BY Age
ORDER BY Age

SELECT *
FROM port_osteo.osteoporosis
