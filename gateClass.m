classdef gateClass < handle
    %GATECLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        axHandle 
        lowLevel
        xPos 
        gap
        highLevel % lowLevel + gap
        width % x direction width
        picXLength % how many points(pixels) the pic has in x direction
        
        lowLeft
        lowRight
        lowBar
        highLeft
        highRight
        highBar
    end
    
    methods
        function this = gateClass(picH, gateGap, lowLevel, xWidth, xPixel, xpos)
            this.axHandle = picH;
            this.gap = gateGap;
            this.lowLevel = lowLevel;
            this.highLevel = this.lowLevel + this.gap;
            this.width = xWidth;
            this.picXLength = xPixel;
            this.xPos = xpos;
            
            set(this.axHandle, 'NextPlot', 'add');
            this.lowLeft = plot(this.axHandle, [this.xPos this.xPos]/this.picXLength, [0 this.lowLevel], 'r'); hold on;
            this.lowRight = plot(this.axHandle, ([this.xPos this.xPos] + this.width)/this.picXLength, [0 this.lowLevel], 'r'); hold on;
            this.lowBar = plot(this.axHandle, [this.xPos this.xPos + this.width]/this.picXLength, [this.lowLevel this.lowLevel], 'r'); hold on;
            this.highLeft = plot(this.axHandle, [this.xPos this.xPos]/this.picXLength, [this.highLevel 1], 'r'); hold on;
            this.highRight = plot(this.axHandle, ([this.xPos this.xPos] + this.width)/this.picXLength, [this.highLevel 1], 'r'); hold on;
            this.highBar = plot(this.axHandle, [this.xPos this.xPos + this.width]/this.picXLength, [this.highLevel this.highLevel], 'r'); hold on;
        end
        
        function delete(this)
            delete(this.lowLeft);
            delete(this.lowRight);
            delete(this.lowBar);
            delete(this.highLeft);
            delete(this.highRight);
            delete(this.highBar);
        end
        
        function p = getXLeft(this)
            p = this.xPos;
        end
        
        function p = getXRight(this)
            p = this.xPos + this.width;
        end
        
        function p = getYLow(this)
            p = this.lowLevel;
        end
        
        function p = getYHigh(this)
            p = this.highLevel;
        end
        
        function this = setXPos(this, xpos)
            this.xPos = xpos;
            this.lowLeft.XData = [this.xPos this.xPos]/this.picXLength;
            this.lowRight.XData = ([this.xPos this.xPos] + this.width)/this.picXLength;
            this.lowBar.XData = [this.xPos this.xPos + this.width]/this.picXLength;
            this.highLeft.XData = this.lowLeft.XData;
            this.highRight.XData = this.lowRight.XData;
            this.highBar.XData = this.lowBar.XData;
        end
        
        function this = setYLevel(this, xlow)
            this.lowLevel = xlow;
            this.highLevel = this.lowLevel + this.gap;
            this.lowLeft.YData = [0 this.lowLevel];
            this.lowRight.YData = [0 this.lowLevel];
            this.lowBar.YData = [this.lowLevel this.lowLevel];
            this.highLeft.YData = [this.highLevel 1];
            this.highRight.YData = [this.highLevel 1];
            this.highBar.YData = [this.highLevel this.highLevel];
        end
        
        function this = stepLeft(this)
            this.xPos = this.xPos - 1;
            this.lowLeft.XData = this.lowLeft.XData - 1/this.picXLength;
            this.lowRight.XData = this.lowRight.XData -1/this.picXLength;
            this.lowBar.XData = this.lowBar.XData -1/this.picXLength;
            this.highLeft.XData = this.highLeft.XData -1/this.picXLength;
            this.highRight.XData = this.highRight.XData -1/this.picXLength;
            this.highBar.XData = this.highBar.XData -1/this.picXLength;
        end
    end
    
end

