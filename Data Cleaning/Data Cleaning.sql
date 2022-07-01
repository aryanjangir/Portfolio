/*
Cleaning Data in SQL Queries
Database name: 'Project'
Tables name: 'House'
*/

select *
from Project.dbo.House

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


select saleDateConverted, CONVERT(Date,SaleDate)
from Project.dbo.House


update House
set SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

alter TABLE House
add SaleDateConverted Date;

update House
set SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from Project.dbo.House
--Where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project.dbo.House a
join Project.dbo.House b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project.dbo.House a
join Project.dbo.House b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from Project.dbo.House
--Where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

from Project.dbo.House


alter TABLE House
add PropertySplitAddress Nvarchar(255);

update House
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


alter TABLE House
add PropertySplitCity Nvarchar(255);

update House
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


select OwnerAddress
from Project.dbo.House


select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from Project.dbo.House



alter TABLE House
add OwnerSplitAddress Nvarchar(255);

update House
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


alter TABLE House
add OwnerSplitCity Nvarchar(255);

update House
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



alter TABLE House
Add OwnerSplitState Nvarchar(255);

update House
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field


select Distinct(SoldAsVacant), Count(SoldAsVacant)
from Project.dbo.House
group by SoldAsVacant
order by 2




select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from Project.dbo.House


update House
set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from Project.dbo.House
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From Project.dbo.House


alter TABLE Project.dbo.House
drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------