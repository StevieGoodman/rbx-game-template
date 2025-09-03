--[=[
    @type ConvertOptions { PrimaryKey: string?, IndexRowsWithHeaders: boolean?}
    @within StringToTable
    A table of options to customize the conversion process.

    **`PrimaryKey`**: The name of the header to use as the key for getting rows. If not provided, rows will be indexed numerically.
    **`IndexRowsWithHeaders`**: When true, rows will be indexed using the header names associated with each cell's column.
]=]
export type ConvertOptions = {
    PrimaryKey: string?,
    IndexRowsWithHeaders: boolean?,
}

--[=[
    @type ConvertResult {[number | string]: {[number | string]: number | string}}
    @within StringToTable
    A 2D table indexed by row, then column.
]=]
export type ConvertResult = {
    [number | string]: {
        [number | string]: number | string
    }
}

--[=[
    @class StringToTable
    A module for converting tab-delimited strings into tables of tables.

    Example usage:
    ```lua
    local StringToTable = require(path.to.StringToTable)

    local inputString = [[
    ID	Name	Age
    1	Alice	30
    2	Bob	25
    StringID	Charlie	35
    ]]

    local options = {
        PrimaryKey = "ID",
        IndexRowsWithHeaders = true,
    }

    local result = StringToTable:Convert(inputString, options)

    -- Result:
    -- {
    --     [1] = { ID = 1, Name = "Alice", Age = 30 },
    --     [2] = { ID = 2, Name = "Bob", Age = 25 },
    --     ["StringID"] = { ID = "StringID", Name = "Charlie", Age = 35 },
    -- }
    ```
]=]

local StringToTable = {}

local function ConvertRowToHeaderArray(headerRow: string): {string}
	local headerArray = string.split(headerRow, "\t")
	for columnNumber, columnHeader in headerArray do
		headerArray[columnNumber] = string.gsub(columnHeader, " ", "")
	end
	return headerArray
end

local function ConvertRowToContentTable(contentRow: string, headerArray: {string}?): {string | number}
	local contentArray = string.split(contentRow, "\t")
	local output = {}
	for columnIndex, cellContent in contentArray do
		columnIndex = if headerArray ~= nil then headerArray[columnIndex] else columnIndex
		output[columnIndex] = tonumber(cellContent) or cellContent
	end
	return output
end

--[=[
    Converts a tab-delimited string into a table of tables.

    @param input -- The tab-delimited multi-line string to convert into a table.
    @param convertOptions -- A table of options to customize the conversion process.

    @return ConvertResult -- The result of the table conversion.
]=]
function StringToTable:Convert(input: string, convertOptions: ConvertOptions?): ConvertResult
    convertOptions = convertOptions or {}

    input = string.gsub(input, "^%s*", "") -- Remove any leading whitespace/newlines
    input = string.gsub(input, "%s*$", "") -- Remove any trailing whitespace/newlines
	local rows = string.split(input, "\n")
	local headerRow = rows[1]
	local contentRows = table.clone(rows)
	table.remove(contentRows, 1) -- Remove header row

	local headerArray = ConvertRowToHeaderArray(headerRow)
	local idHeaderIndex = if convertOptions.PrimaryKey ~= nil then table.find(headerArray, convertOptions.PrimaryKey) else nil
	local hasIdHeader = idHeaderIndex ~= nil

	local output = {}
	for rowIndex, rowContent in contentRows do
		local contentTable = ConvertRowToContentTable(rowContent, if convertOptions.IndexRowsWithHeaders then headerArray else nil)
		rowIndex =
			if hasIdHeader then
				if convertOptions.IndexRowsWithHeaders then contentTable[convertOptions.PrimaryKey]
				else contentTable[idHeaderIndex]
			else rowIndex
		output[rowIndex] = contentTable
	end

	return output
end

return StringToTable