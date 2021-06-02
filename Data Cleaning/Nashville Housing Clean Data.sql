/*
Cleaning Data
*/

Select *
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------

-- Date Format

Select SaleDate, CONVERT(Date,saledate)
from PortfolioProject..NashvilleHousing

ALTER Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate)


---------------------------------------------------------------------------------------------

-- Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

 
 Update a
 SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------

--Breaking out Address into (Adress, City, State)

Select propertyaddress
from PortfolioProject..NashvilleHousing

Select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress) +1, LEN(propertyaddress)) as Address
from PortfolioProject..NashvilleHousing

ALTER Table NashvilleHousing
Add PropertySpiltAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySpiltAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER Table NashvilleHousing
Add PropertySpiltCity Nvarchar(255);

Update NashvilleHousing
SET PropertySpiltCity = SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress) +1, LEN(propertyaddress))



Select owneraddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACe(OwnerAddress,',','.'),3)
,PARSENAME(REPLACe(OwnerAddress,',','.'),2)
,PARSENAME(REPLACe(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

ALTER Table NashvilleHousing
Add OwnerSpiltAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSpiltAddress = PARSENAME(REPLACe(OwnerAddress,',','.'),3)

ALTER Table NashvilleHousing
Add OwnerSpiltCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSpiltCity = PARSENAME(REPLACe(OwnerAddress,',','.'),2)

ALTER Table NashvilleHousing
Add OwnertySpiltState Nvarchar(255);

Update NashvilleHousing
SET OwnertySpiltState = PARSENAME(REPLACe(OwnerAddress,',','.'),1)


Select *
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by COUNT(SoldAsVacant)

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsvacant = 'N' THEN 'No'
		Else SoldAsVacant
		End
from PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsvacant = 'N' THEN 'No'
		Else SoldAsVacant
		End
------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num

from PortfolioProject..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

--------------------------------------------------------------------------------------------------------------------------

-- Delte Unused Columns (Just for practicing)

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN saledate
