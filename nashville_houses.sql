
SELECT SaleDate
FROM NASHVILLE_HOUSING;

-- convert date like 2013-04-09 to April 9 2013
SELECT TO_CHAR(saledate, 'YYYY DD Month')
FROM nashville_housing;

--store converted date permanatley 
ALTER TABLE nashville_housing 
ALTER COLUMN saledate TYPE TEXT 
USING TO_CHAR(saledate, 'YYYY DD Month');

--populate propery address data


SELECT *
FROM nashville_housing
WHERE PropertyAddress is null;
--order by ParcelID;

SELECT A.ParcelID ,A.PropertyAddress,B.ParcelID,B.PropertyAddress,COALESCE(A.propertyaddress, B.propertyaddress)
FROM nashville_housing A
JOIN nashville_housing B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress is null;

UPDATE nashville_housing A
SET propertyaddress = COALESCE(A.propertyaddress, B.propertyaddress)
FROM nashville_housing B
WHERE A.parcelid = B.parcelid
AND A.uniqueid <> B.uniqueid
AND A.propertyaddress IS NULL;

--Breaking Out Address into individual columns ( address ,city,state)

SELECT PropertyAddress
FROM nashville_housing;
--WHERE PropertyAddress is null;
--order by ParcelID;

SELECT 
SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1) AS address,
SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress)) AS city
FROM nashville_housing;
-- -1 to skip comma in first substring,+1 to skip comma in second substring to 

ALTER TABLE nashville_housing
ADD COLUMN propertysplitaddress TEXT;

UPDATE nashville_housing
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1);

ALTER TABLE nashville_housing
ADD COLUMN propertysplitcity TEXT;

UPDATE nashville_housing
SET propertysplitcity = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress));

SELECT propertyaddress, propertysplitaddress, propertysplitcity
FROM nashville_housing
LIMIT 10;

-- Split Owner Address 
SELECT OwnerAddress
FROM nashville_housing;

SELECT
SPLIT_PART(owneraddress, ',', 1) AS owner_street,
SPLIT_PART(owneraddress, ',', 2) AS owner_city,
SPLIT_PART(owneraddress, ',', 3) AS owner_state
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN ownersplitaddress TEXT;

UPDATE nashville_housing
SET ownersplitaddress = SPLIT_PART(owneraddress, ',', 1);

ALTER TABLE nashville_housing
ADD COLUMN ownersplitcity TEXT;

UPDATE nashville_housing
SET ownersplitcity = SPLIT_PART(owneraddress, ',', 2);

ALTER TABLE nashville_housing
ADD COLUMN ownersplitstate TEXT;

UPDATE nashville_housing
SET ownersplitstate = SPLIT_PART(owneraddress, ',', 3);

SELECT owneraddress, ownersplitaddress, ownersplitcity, ownersplitstate
FROM nashville_housing;

-- Change Y and N to Yes and No in 'Sold as Vacant'

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant;

SELECT soldasvacant, 
CASE 
    WHEN soldasvacant = 'Y' THEN 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
END
FROM nashville_housing;

UPDATE nashville_housing
SET soldasvacant = CASE 
    WHEN soldasvacant = 'Y' THEN 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
END;

--Remove Duplicates ( ASSUMING uniqueid doesnt exist ) , 
--partition by to see the combination of propertaddress + price + date + legalref to see if there is repititon

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY parcelid,
                         propertyaddress,
                         saleprice,
                         saledate,
                         legalreference
                         ORDER BY uniqueid) AS row_num
    FROM nashville_housing
)
DELETE FROM nashville_housing
WHERE uniqueid IN (
    SELECT uniqueid FROM RowNumCTE
    WHERE row_num > 1
);

-- Delete Unused Columns

ALTER TABLE nashville_housing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;


