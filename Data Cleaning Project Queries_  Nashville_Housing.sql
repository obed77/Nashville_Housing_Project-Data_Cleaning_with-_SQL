/*
Cleaning Data in SQL Queries
*/


Select *
From projects.dbo.nashville_housing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE nashville_housing
Add SaleDateConverted Date;

Update nashville_housing
SET SaleDateConverted = CONVERT(Date,SaleDate);


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From projects.dbo.nashville_housing
order by ParcelID;



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From projects.dbo.nashville_housing a
JOIN projects.dbo.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From projects.dbo.nashville_housing a
JOIN projects.dbo.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From projects.dbo.nashville_housing;


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From projects.dbo.nashville_housing;


ALTER TABLE nashville_housing
Add PropertySplitAddress Nvarchar(255);

Update nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE nashville_housing
Add PropertySplitCity Nvarchar(255);

Update nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));



Select *
From projects.dbo.nashville_housing;



Select OwnerAddress
From projects.dbo.nashville_housing;


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From projects.dbo.nashville_housing;



ALTER TABLE nashville_housing
Add OwnerSplitAddress Nvarchar(255);

Update nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE nashville_housing
Add OwnerSplitCity Nvarchar(255);

Update nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);



ALTER TABLE nashville_housing
Add OwnerSplitState Nvarchar(255);

Update nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);



Select *
From projects.dbo.nashville_housing;




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From projects.dbo.nashville_housing
Group by SoldAsVacant
order by 2;




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From projects.dbo.nashville_housing;


Update nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;






-----------------------------------------------------------------------------------------------------------------------------------------------------------

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

From projects.dbo.nashville_housing

)
DELETE
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;



Select *
From projects.dbo.nashville_housing;




---------------------------------------------------------------------------------------------------------

-- Delete Unwanted Columns



Select *
From projects.dbo.nashville_housing;


ALTER TABLE projects.dbo.nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;