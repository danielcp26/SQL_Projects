-- DATA CLEANING

-- POPULATE PROPERTY ADDRESS DATA

SELECT propertyaddress
FROM nashville_housing
WHERE propertyaddress IS NULL;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress) 
FROM nashville_housing a
JOIN nashville_housing b
    ON a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

UPDATE nashville_housing a
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing b
WHERE a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
AND a.propertyaddress IS NULL;

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

-- PROPERTYADDRESS: SPLITTING STREET ADDRESS AND CITY

SELECT DISTINCT(propertyaddress)
FROM nashville_housing;

SELECT propertyaddress, SPLIT_PART(propertyaddress, ',', 2) AS city
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD propertysplitaddress TEXT;

UPDATE nashville_housing
SET propertysplitaddress = SPLIT_PART(propertyaddress, ',', 1);

ALTER TABLE nashville_housing
ADD propertysplitaddresscity TEXT;

UPDATE nashville_housing
SET propertysplitaddresscity = SPLIT_PART(propertyaddress, ',', 2);

SELECT *
FROM nashville_housing;

-- OWNERADDRESS: SPLITTING STREET, CITY, AND STATE

SELECT owneraddress
FROM nashville_housing;

SELECT owneraddress, SPLIT_PART(owneraddress, ',', 3) AS state, 
SPLIT_PART(owneraddress, ',', 2) AS city, 
SPLIT_PART(owneraddress, ',', 1) AS address
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD ownersplitaddress TEXT;

UPDATE nashville_housing
SET ownersplitaddress = SPLIT_PART(owneraddress, ',', 1);

ALTER TABLE nashville_housing
ADD ownersplitcity TEXT;

UPDATE nashville_housing
SET ownersplitcity = SPLIT_PART(owneraddress, ',', 2);

ALTER TABLE nashville_housing
ADD ownersplitstate TEXT;

UPDATE nashville_housing
SET ownersplitstate = SPLIT_PART(owneraddress, ',', 3);

SELECT * FROM nashville_housing;

-- CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN 'SOLD AS VACANT' FIELD

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY 2;

SELECT soldasvacant,
    CASE WHEN soldasvacant = 'Y' THEN 'Yes'
         WHEN soldasvacant = 'N' THEN 'No'
         ELSE soldasvacant
    END
FROM nashville_housing;

UPDATE nashville_housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END;

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY 2;

-- REMOVE DUPLICATES WHILE KEEPING THE FIRST OCCURRENCE

WITH rownumcte AS (
    SELECT uniqueid
    FROM (
        SELECT uniqueid,
               ROW_NUMBER() OVER (
                   PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
                   ORDER BY uniqueid
               ) AS row_num
        FROM nashville_housing
    ) AS subquery  
    WHERE row_num > 1  
)

DELETE FROM nashville_housing 
WHERE uniqueid IN (SELECT uniqueid FROM rownumcte);

-- DELETE UNUSED COLUMNS TO CLEAN DATASET

ALTER TABLE nashville_housing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;

SELECT * FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN saledate;
