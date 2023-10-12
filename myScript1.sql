/*
Cleaned Data in Sql
*/

Select * 
From NashvilleHousingDataCleaning

---------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted,Convert(Date,SaleDate)
From NashvilleHousingDataCleaning

Update NashvilleHousingDataCleaning
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousingDataCleaning
Add SaleDateConverted Date;

Update NashvilleHousingDataCleaning
Set SaleDateConverted= Convert(Date,SaleDate)

--------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From NashvilleHousingDataCleaning
--Where PropertyAddress is Null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isNull(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousingDataCleaning a
join NashvilleHousingDataCleaning b
on a.ParcelID=b.ParcelID
And a.UniqueID<>b.UniqueID
where a.PropertyAddress is null


-------------------------------------------------------------------------------------------------------

--Breaking out Address into individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousingDataCleaning

Select Substring(PropertyAddress, 1, CharIndex(',',PropertyAddress) -1) as address
,Substring(PropertyAddress, CharIndex(',',PropertyAddress) +1, len(PropertyAddress)) as address
From NashvilleHousingDataCleaning


Alter Table NashvilleHousingDataCleaning
Add PropertySplitAddress nVarchar(255);

Update NashvilleHousingDataCleaning
Set PropertySplitAddress= Substring(PropertyAddress, 1, CharIndex(',',PropertyAddress) -1)

Alter Table NashvilleHousingDataCleaning
Add PropertySplitCity nVarchar(255);

Update NashvilleHousingDataCleaning
Set PropertySplitCity= Substring(PropertyAddress, CharIndex(',',PropertyAddress) +1, len(PropertyAddress))

Select *
From NashvilleHousingDataCleaning

Select OwnerAddress
From NashvilleHousingDataCleaning

Select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From NashvilleHousingDataCleaning

Alter Table NashvilleHousingDataCleaning
Add OwnerSplitAddress nVarchar(255);

Update NashvilleHousingDataCleaning
Set OwnerSplitAddress= PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousingDataCleaning
Add OwnerSplitCity nVarchar(255);

Update NashvilleHousingDataCleaning
Set OwnerSplitCity= PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousingDataCleaning
Add OwnerSplitState nVarchar(255);

Update NashvilleHousingDataCleaning
Set OwnerSplitState= PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From NashvilleHousingDataCleaning

----------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From NashvilleHousingDataCleaning
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
From NashvilleHousingDataCleaning

Update NashvilleHousingDataCleaning
set SoldAsVacant=Case When SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
From NashvilleHousingDataCleaning

----------------------------------------------------------------------------------------------------------

--Remove Duplicates
With my_cte as(
Select *,
ROW_NUMBER() over(partition by ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) row_num
From NashvilleHousingDataCleaning

)

Select *
From my_cte
where row_num >1
order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------

--Delete unused Columns


Select *
From NashvilleHousingDataCleaning

Alter Table NashvilleHousingDataCleaning
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table NashvilleHousingDataCleaning
Drop Column SaleDate


-------------------------------------------------------------------------------------------------------------------
