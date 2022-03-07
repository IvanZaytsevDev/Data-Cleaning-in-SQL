SELECT *
FROM HousingData.dbo.housingData

-- Change date format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM HousingData.dbo.housingData

UPDATE HousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE housingData
ADD SaleDateConverted Date

UPDATE HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM HousingData.dbo.housingData

-- Populate property address data
SELECT *
FROM HousingData.dbo.housingData
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM HousingData.dbo.housingData as a
JOIN HousingData.dbo.housingData as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM HousingData.dbo.housingData as a
JOIN HousingData.dbo.housingData as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Split address into individual columns (address, city, state)
SELECT PropertyAddress
FROM HousingData.dbo.housingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM HousingData.dbo.housingData

ALTER TABLE housingData
ADD PropertySplitAddress Nvarchar(255)

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE housingData
ADD PropertySplitCity Nvarchar(255)

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM HousingData.dbo.housingData

SELECT OwnerAddress
FROM HousingData.dbo.housingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
FROM HousingData.dbo.housingData

ALTER TABLE housingData
ADD OwnerSplitAddress Nvarchar(255)

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE housingData
ADD OwnerSplitCity Nvarchar(255)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE housingData
ADD OwnerSplitState Nvarchar(255)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM HousingData.dbo.housingData

-- Change Y and N to Yes and No in "SoldAsVacantt" column

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM HousingData.dbo.housingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'Yes'
	  ELSE SoldAsVacant
	  END
FROM HousingData.dbo.housingData

Update housingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'Yes'
	  ELSE SoldAsVacant
	  END

-- Remove duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM HousingData.dbo.housingData
)
DELETE
FROM RowNumCTE
WHERE row_num <> 1

-- Delete unused columns

SELECT *
FROM HousingData.dbo.housingData

ALTER TABLE HousingData.dbo.housingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate