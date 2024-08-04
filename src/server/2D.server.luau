local Grid = {}
Grid.__index = Grid



function Grid:New()
	local n, m = 10, 20
	local self = {}
	local thisGrid = {} 
	
	for i = 1, n do
		local thisRow = {}
		table.insert(thisGrid, thisRow)
		for j = 1, m do
			table.insert(thisRow, 0)
		end
	end	
	thisGrid[1][5] = 1
	thisGrid[2][5] = 1
	thisGrid[3][5] = 1
	thisGrid[4][5] = 1
	
	thisGrid[1][6] = 1
	thisGrid[2][6] = 1
	thisGrid[3][6] = 1
	thisGrid[4][6] = 1
	
	thisGrid[1][7] = 1
	thisGrid[2][7] = 1
	thisGrid[3][7] = 1
	thisGrid[4][7] = 1
	
	
	self.grid = thisGrid
	return setmetatable(self, Grid)
end

function Grid:Print()
	local str = "\n"
	for i, row in pairs(self.grid) do
		for j, val in pairs(row) do
			str = str .. tostring(val)
		end
		str = str .. "\n"
	end
	print(str)
end

function Grid:isInBounds(x: number, y: number)
	return not (self.grid[x] == nil or self.grid[x] ~= nil and self.grid[x][y] == nil)
end

function Grid:Step()
	self.grid[1][5] = 1
	local nextBoard = DeepCopy(self.grid)
	local touched = {}

	for i = #self.grid, 1, -1 do  -- Iterate from bottom to top
		for j = 1, #self.grid[i] do
			if self.grid[i][j] == 1 then  -- Check if the current cell contains a sand particle
				local belowRow = i + 1
				-- Check if the cell below is within bounds and is empty
				if self:isInBounds(belowRow, j) and nextBoard[belowRow][j] == 0 then
					nextBoard[belowRow][j] = 1  -- Move the particle down
					nextBoard[i][j] = 0  -- Clear the current position
				elseif self:isInBounds(belowRow, j) and nextBoard[belowRow][j] == 2 then
					
					local lorr = if math.random() > .5 then 1 else (-1)
					

					if self:isInBounds(i, j + lorr) and nextBoard[i][j + lorr] == 0 then
						nextBoard[i][j + lorr] = 1
						nextBoard[i][j] = 0
					elseif self:isInBounds(i, j - lorr) and nextBoard[i][j - lorr] == 0 then
						nextBoard[i][j - lorr] = 1
						nextBoard[i][j] = 0
					else
						nextBoard[i][j] = 2
					end
				elseif not self:isInBounds(belowRow, j) then
					nextBoard[i][j] = 2
				end
				
			elseif self.grid[i][j] == 2 then
				if self:isInBounds(i, j + 1) and self:isInBounds(i, j - 1) and nextBoard[i][j - 1] == 0 and nextBoard[i][j + 1] then
					--nextBoard[i][j + 1] = 2
					--nextBoard[i][j - 1] = 2
					nextBoard[i][j] = 1
				end
			end
		end
	end
	
	
	self.grid = nextBoard
end


function DeepCopy(t: {})
	local tClone = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			tClone[k] = DeepCopy(v)
		else
			tClone[k] = v
		end
	end
		
	return tClone
end
local board = Grid:New()

board:Print()

while 1 do
	task.wait(.1)
	board:Step()
	board:Print()
end