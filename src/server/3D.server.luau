local Deque = require(script.Parent.Queue)

local Grid3D = {}
Grid3D.__index =  Grid3D


local CellStates = {
	ALIVE = "ALIVE",
	STUCK = "STUCK",
	EMPTY = "EMPTY",	
}
local Cell = {}

function Cell.new(part)
	return {STATE = CellStates.EMPTY, PART = part, TARGET = nil}
end

function Grid3D.new(n, m, o)
	local self = {}
	setmetatable(self, Grid3D)
	local model = Instance.new("Model", workspace)
	local Grid = {}
	for i = 1, n do
		Grid[i] = {}
		for j = 1, m do
			Grid[i][j] = {}
			for k = 1, o do
				local part = Instance.new("Part")
				part.Name = i..','..j..','..k
				part.Anchored = true
				part.Size = Vector3.new(1,1,1)
				part.Parent = model
				part.Position = Vector3.new(i, k, j) + Vector3.new(0,10,0)
				
				
				Grid[i][j][k] = Cell.new(part)
				self:ColorCell(Grid[i][j][k])
				
			end
		end
	end

	self.Grid = Grid
	return self
end

function Grid3D:isInBounds(x: number, y: number, z: number)
	return not (self.Grid[x] == nil or self.Grid[x][y] == nil or self.Grid[x][y][z] == nil) 		
end

function Grid3D:Step()
	
	local nextBoard = DeepCopy(self.Grid)

	for i = #self.Grid, 1, -1 do  -- Iterate from bottom to top
		for j = 1, #self.Grid[i] do
			
			for k = 1, #self.Grid[i][j] do
				
				local belowRow = k - 1				
				if nextBoard[i][j][k].STATE == CellStates.ALIVE then
					if not self:isInBounds(i, j, belowRow) then
						nextBoard[i][j][k].STATE = CellStates.STUCK
						continue
					end
					
					if nextBoard[i][j][belowRow].STATE == CellStates.STUCK then
						--Currently unused
						if false and nextBoard[i][j][k].TARGET == nil then
							nextBoard[i][j][k].TARGET = self:FindNextEmptyOnLevelBFS{X = i, Y = j, Z = belowRow}
						end
						
						local spotFound = false
						for _, dirI in shuffleArray{-1, 0, 1} do
							if spotFound then break end;
							
							for __, dirJ in shuffleArray{-1, 0, 1} do
								
								if 0 == dirJ and dirJ == dirI then
									continue
								end
								
								if spotFound then break end;
								
								if self:isInBounds(i + dirI, j + dirJ, k) and nextBoard[i + dirI][j + dirJ][k].STATE == CellStates.EMPTY then
									spotFound = true
									nextBoard[i + dirI][j + dirJ][k].STATE = CellStates.ALIVE
									nextBoard[i][j][k].STATE = CellStates.EMPTY
									self:ColorCell(self.Grid[i + dirI][j + dirJ][k])
								end
							end
						end
						
						if not spotFound then
							nextBoard[i][j][k].STATE = CellStates.STUCK
						end	
						

					else
						nextBoard[i][j][belowRow].STATE = CellStates.ALIVE
						nextBoard[i][j][k].STATE = CellStates.EMPTY
					end
					self:ColorCell(nextBoard[i][j][belowRow])
				end 	
				self:ColorCell(nextBoard[i][j][k])
			end
		end
	end
	self.Grid = nextBoard
end

function Grid3D:ColorCell(cell)
	if cell.STATE == CellStates.ALIVE then
		cell.PART.Transparency = 0.5
	elseif cell.STATE == CellStates.EMPTY then
		cell.PART.Transparency = 1	
	elseif cell.STATE == CellStates.STUCK then
		cell.PART.BrickColor = BrickColor.Red()
		cell.PART.Transparency = 0
	end
end

-- Currently cells just randomly look for a direction once they are stuck above another. This api could be use to do this more intelgently 
function Grid3D:FindNextEmptyOnLevelBFS(start: {X: number, Y: number, Z: number})
	local visted = {}
	local queue = Deque.new()
	queue:Enqueue(start)

	while not queue:IsEmpty() do
		
		local cur = queue:PopLeft()
		local curAsVisited = table.concat({cur.X, cur.Y, cur.Z}, "\\")
		if self:isInBounds(cur.X, cur.Y, cur.Z) and self.Grid[cur.X][cur.Y][cur.Z].STATE == CellStates.EMPTY then
			return cur		
		end
		if self:isInBounds(cur.X, cur.Y, cur.Z) and visted[curAsVisited] == nil then
			visted[table.concat({cur.X, cur.Y, cur.Z}, "\\") ] = true
			for _, dirI in {-1, 0, 1} do
				for __, dirJ in {-1, 0, 1} do
					
					if 0 == dirJ and dirJ == dirI then continue end;
					
					local asVisited = table.concat({cur.X + dirI, cur.Y + dirJ, cur.Z}, "\\")
					if self:isInBounds(cur.X + dirI, cur.Y + dirJ, cur.Z) and visted[asVisited] == nil then

						queue:Enqueue({X = cur.X + dirI, Y = cur.Y + dirJ, Z = cur.Z})
				
					end
				end
			end
		end
	end
	
	return nil -- Not found :(

end


-- Array util
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

function shuffleArray(array)
	local n = #array 
	for i = n, 2, -1 do		
		local j = math.random(1, i)		
		array[i], array[j] = array[j], array[i]
	end
	return array  
end


-- Runner 

local RunService = game:GetService("RunService")
local board = Grid3D.new(10, 10, 25)


	
task.wait(2)
local startTime = tick()
local mid1 = math.floor( #board.Grid / 2 )
local mid2 = math.floor( #board.Grid[1] / 2 )
while true do
	-- 'Poor' particles in for the first few seconds

	for i = 1, 3 do
		board:Step()	
		if tick() - startTime < 1.5 then 
			board.Grid[mid1][mid2][#board.Grid[1][1]].STATE = "ALIVE"
		end
	end
	
	RunService.Heartbeat:Wait()	
end

