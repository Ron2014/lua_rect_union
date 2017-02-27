
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 960,
    height = 640,
    autoscale = "FIXED_HEIGHT",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "FIXED_WIDTH"}
        end
    end
}

UNIT_SIZE = 32
UNIT_SIZE_REC = 1/UNIT_SIZE

COLUMN = CC_DESIGN_RESOLUTION.width / UNIT_SIZE -- 30
COLUMN_REC = 1/COLUMN

ROW = CC_DESIGN_RESOLUTION.height / UNIT_SIZE   -- 20

function getRowAndColumnById(id)
    local col = (id-1) % COLUMN + 1
    local row = math.ceil(id * COLUMN_REC)
    return row, col
end

function getIdByRowAndColumn(row, col)
    return (row - 1) * COLUMN + col
end

function getPositionById(id)
    local row, col = getRowAndColumnById(id)
    return (col-1)*UNIT_SIZE, (row-1)*UNIT_SIZE
end

function getIdByPosition(x, y)
    if not y then
        y = x.y
        x = x.x
    end

    local col = math.ceil(x * UNIT_SIZE_REC)
    local row = math.ceil(y * UNIT_SIZE_REC)
    return getIdByRowAndColumn(row, col)
end