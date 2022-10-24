

Select*
From PortfolioProject.dbo.NashvilleHousingDB

------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousingDB

Update NashvilleHousingDB
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousingDB
Add SaleDateConverted Date;

Update NashvilleHousingDB
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousingDB
--Where propertyaddress is null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.propertyaddress)
From PortfolioProject.dbo.NashvilleHousingDB a
JOIN PortfolioProject.dbo.NashvilleHousingDB b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
From PortfolioProject.dbo.NashvilleHousingDB a
JOIN PortfolioProject.dbo.NashvilleHousingDB b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousingDB
--Where propertyaddress is null
--Order By ParcelID


Select
Substring(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1 ) as Address
 , Substring(propertyaddress, CHARINDEX(',', propertyaddress) +1 , LEN(propertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousingDB


ALTER TABLE NashvilleHousingDB
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousingDB
SET PropertySplitAddress = Substring(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1 )


ALTER TABLE NashvilleHousingDB
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousingDB
SET PropertySplitCity = Substring(propertyaddress, CHARINDEX(',', propertyaddress) +1 , LEN(propertyaddress))


Select *
From PortfolioProject.dbo.NashvilleHousingDB



Select owneraddress
From PortfolioProject.dbo.NashvilleHousingDB

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject.dbo.NashvilleHousingDB




ALTER TABLE NashvilleHousingDB
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousingDB
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousingDB
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousingDB
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE NashvilleHousingDB
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousingDB
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)






-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousingDB
Group by SoldAsVacant
Order By 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousingDB


Update NashvilleHousingDB
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END



-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDAte,
				LegalReference
				ORDER By 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousingDB
)
DELETE
From RowNumCTE
Where row_num > 1






-- Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousingDB

ALTER TABLE PortfolioProject.dbo.NashvilleHousingDB
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousingDB
Drop Column SaleDate