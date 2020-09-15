%{
if you do the dual click on an incomplete tile, show which it touches

need to seed the random numbers on first open

improve gridGen speed by limiting certain ops to only a size grater than 1

clicking might be a bit off on large blobs
- is it that U shape issue that i fixed in kenken?

some display of winning

make firstclick only add mines on the first left click

text size in resizing

if you flag a tile that ends up being next to a 0, it will be flagged and
cleared

Ui labels are off on most screens
--try using 'characters' units for position

reveal mines differently?
-square changes color?
-don't show flagged mines?
- show incorrect flags?
%}
function [] = Minesweeper()
	clc
	f = [];
	ax = [];
	squares = square.empty;
	indGrid = [];
	mineCount = [];
	rowT = [];
	colT = [];
	mineT = [];
	sizeT = [];
	
	gameOver = false;
	
	figureSetup();
	newGame();
	
	
	function [] = newGame(~,~)
		cla(ax);
		[squares, indGrid] = square.gridGen(str2double(rowT.String),str2double(colT.String), str2double(sizeT.String)); %40 mines
		
		f.WindowButtonUpFcn = @firstClick;
		mineCount.String = mineT.String;
		gameOver = false;
	end
	
	function [] = firstClick(~,~)
		% guarantees that first click is a zero
		m = -1+round(0.5+ax.CurrentPoint(1,1:2));
		if ~(m(2) > 0 && m(2) <= size(indGrid,1) && m(1) > 0 && m(1) <= size(indGrid,2))
			return % clicking outside grid
		end
		square.addMines(squares,indGrid,mineT,m);
		mineCount.String = mineT.String;
		f.WindowButtonUpFcn = @click;
		click(1,1)
	end
	
	function [] = click(~,~)
		if gameOver
% 			gameOver
			return
		end
		if strcmp(f.SelectionType,'open') % ignore double click
			% this is ignored because it doesn't differentiate left vs
			% right click when double clicking.
			return
		end
		
		% get the square that was clicked
		m = -1+round(0.5+ax.CurrentPoint(1,1:2));
		if ~(m(2) > 0 && m(2) <= size(indGrid,1) && m(1) > 0 && m(1) <= size(indGrid,2))
			return % clicking outside grid
		end
		sq = squares(indGrid(m(2),m(1)));
		
		switch f.SelectionType
			case 'alt' % right click, flag
				if ~sq.isClear
					mineCount.String = num2str( str2double(mineCount.String) - sq.flag() ); % flag and change mine count
				end
			case 'extend' % both buttons, reveal adj
				%would be cool if it highlighted adj, unrevealed squares
				if sq.isClear && ~sq.isFlag
					s = sum([squares(sq.adjInd).isFlag]);
					if s == sq.number
						for i = sq.adjInd
							if ~squares(i).isClear && ~squares(i).isFlag
								recClick(squares(i));
							end
						end
					end
				end
			case 'normal' % left clickk, reveal sq
				if ~sq.isClear && ~sq.isFlag
					recClick(sq);
				end
		end
		if ~gameOver && ((sum([squares.isClear]) + sum([squares.isMine]) == length(squares)) || (sq.isMine && ~sq.isFlag && strcmp(f.SelectionType,'normal')))
			gameOver = true;
			% show a check mark or something
		end
	end
	
	function [] = recClick(sq)
		if sq.isMine
			for i = 1:length(squares)
				if squares(i).isMine
					squares(i).mineT.Visible = 'on';
% 					gameOver = true;
				end
			end
		elseif sq.number == 0
			sq.isClear = true;
			for i = 1:length(sq.adjInd)
				if ~squares(sq.adjInd(i)).isClear
					recClick(squares(sq.adjInd(i)))
				end
			end
		else
			sq.showNumText();
			sq.isClear = true;
		end
		sq.p.FaceColor = sq.c2;
	end
	
	function [] = figureSetup()
		f = figure(1);
		clf
		f.MenuBar = 'none';
		f.SizeChangedFcn = @resize;
		f.WindowButtonUpFcn = @firstClick;

		ax = axes('Parent',f);
		ax.Color = f.Color;
		ax.Position = [0 0 1 0.9];
		ax.YDir = 'reverse';
		ax.XTick = [];
		ax.YTick = [];
		axis equal
		
		ng = uicontrol('Style','pushbutton','Units','normalized','Position',[0.45 0.91, 0.1 0.08],'String', 'New Game','Callback',@newGame);
		
		rowT = uicontrol('Style','edit','Units','normalized','Position',[0.065 0.92, 0.05 0.06],'String','15','FontSize',20);
		colT = uicontrol('Style','edit','Units','normalized','Position',[0.17 0.92, 0.05 0.06],'String','25','FontSize',20);
		mineT = uicontrol('Style','edit','Units','normalized','Position',[0.29 0.92, 0.05 0.06],'String','30','FontSize',20);
		sizeT = uicontrol('Style','edit','Units','normalized','Position',[0.395 0.92, 0.05 0.06],'String',num2str(randi(3)),'FontSize',20);
		
		rowLbl = uicontrol('Style','text','Units','normalized','Position',[0.005 0.92, 0.06 0.055],'String','Rows:','HorizontalAlignment','right','FontSize',20);
		colLbl = uicontrol('Style','text','Units','normalized','Position',[0.13 0.92, 0.04 0.055],'String','Cols:','HorizontalAlignment','right','FontSize',20);
		mineLbl = uicontrol('Style','text','Units','normalized','Position',[0.235 0.92, 0.055 0.055],'String','Mines:','HorizontalAlignment','right','FontSize',20);
		sizeLbl = uicontrol('Style','text','Units','normalized','Position',[0.355 0.92, 0.04 0.055],'String','Size:','HorizontalAlignment','right','FontSize',20);
		
		mineCount = uicontrol('Style','text','Units','normalized','Position',[0.7 0.92, 0.07 0.055],'String',mineT.String,'HorizontalAlignment','center','FontSize',20,'BackgroundColor',f.Color*0.9);
		
		mcLbl = uicontrol('Style','text','Units','normalized','Position',[0.61 0.92, 0.09 0.055],'String','Mines: ','HorizontalAlignment','center','FontSize',20);
		
	end
				
	function [] = resize(~,~)
		axis equal
	end
end













