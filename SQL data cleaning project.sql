SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing;

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted 
FROM NashvilleHousing; 


-- Populate Property Address data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID;


--Self Joins 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID = b.ParcelID 
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Portfolio_Project.[dbo].[NashvilleHousing]
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM Portfolio_Project.[dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Dividing the string values of the OwnerAddress

SELECT OwnerAddress
FROM Portfolio_Project.[dbo].[NashvilleHousing]


SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Project.[dbo].[NashvilleHousing]


ALTER TABLE Portfolio_Project.[dbo].[NashvilleHousing]
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Portfolio_Project.[dbo].[NashvilleHousing] 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE Portfolio_Project.[dbo].[NashvilleHousing]
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Portfolio_Project.[dbo].[NashvilleHousing] 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Portfolio_Project.[dbo].[NashvilleHousing]
ADD OwnerSplitState NVARCHAR(255);

UPDATE Portfolio_Project.[dbo].[NashvilleHousing] 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT DISTINCT(SoldAsVacant)
FROM Portfolio_Project.[dbo].[NashvilleHousing]

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.[dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio_Project.[dbo].[NashvilleHousing]

UPDATE Portfolio_Project.[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio_Project.[dbo].[NashvilleHousing]
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio_Project.[dbo].[NashvilleHousing]
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1



-- Delete Unused Columns


Select *
From Portfolio_Project.[dbo].[NashvilleHousing]

ALTER TABLE Portfolio_Project.[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate