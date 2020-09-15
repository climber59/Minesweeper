classdef square < handle
	properties
		row
		col
		isMine
		isClear
		isFlag
		
		p
		c = [0.9 0.9 0.9];
		c2 = [1 1 1]*0.7;
		
		number
		
		adjInd
		
		flagT
		numT
		mineT
		
		t_loc
	end
	
	methods
		function obj = square(rc,verts)
			if nargin>0
				obj.p = patch(verts(:,2),verts(:,1),obj.c);
				obj.isMine = false;
				obj.isClear = false;
				obj.isFlag = false;
				
				%row,col
				obj.col = rc(:,2);
				obj.row = rc(:,1);
				
				obj.number = 0;
				obj.adjInd = [];
				obj.t_loc = [round(mean(obj.col))+0.5, round(mean(obj.row))+0.5];
				obj.flagT = text(obj.t_loc(1),obj.t_loc(2), 'f','HorizontalAlignment','center','Color',[1 0 0],'FontSize',20,'Visible','off');
			end
		end
		
		function [a] = flag(sq)
			if sq.isFlag
				sq.flagT.Visible = 'off';
				a = -1;
			else
				sq.flagT.Visible = 'on';
				a = 1;
			end
			sq.isFlag = ~sq.isFlag;
			sq.p.FaceColor = sq.c*(-sign(a-1)) + sign(a+1)*[0.9 0.8 0.8];
		end
		
		function [] = showNumText(sq)
			sq.numT.Visible = 'on';
		end
	end
	
	methods (Static)
		function [] = adjacents(squares, indGrid)
% 			indGrid
			for i = 1:length(squares) % should theoretically work for any shape
				rc = [];
				for j = 1:length(squares(i).row)
					r = squares(i).row(j);
					c = squares(i).col(j);
					rc = [rc; [r-1 r r+1 r+1 r+1 r r-1 r-1]' [c-1 c-1 c-1 c c+1 c+1 c+1 c]'];
				end
				for j = 1:length(rc)
					if rc(j,1) ~= 0 && rc(j,1) ~= size(indGrid,1)+1 && rc(j,2) ~= 0 && rc(j,2) ~= size(indGrid,2)+1
						k = indGrid(rc(j,1),rc(j,2));
						if k~=i && ~any(squares(i).adjInd == k) % ignore self and duplicates
							squares(i).adjInd(end+1) = k;
						end
					end
				end
			end
		end
		
		function [squares] = addMines(squares, indGrid, mineT, mouse)
			j = indGrid(mouse(2),mouse(1));
			j = [j, squares(j).adjInd];
			
			m = str2double(mineT.String);
			if m>length(squares)-length(j) || m<=0
				m = ceil(length(squares)/5);
				mineT.String = num2str(m);
			end
			
			
			
			for i=1:m
				k = randi(length(squares));
				while squares(k).isMine == true || any(k == j)
					k = randi(length(squares));
				end
				squares(k).isMine = true;
			end
			
			numColors =[1 0 254;...
				1 127 1;...
				254 0 0;...
				1 0 128;...
				129 1 2;...
				0 128 129;...
				0 0 0;...
				128 128 128;...
				128 1 128;...
				128 128 1;...
				]./255;
			for i = 1:length(squares)
				if squares(i).isMine
					squares(i).mineT = text(squares(i).t_loc(1),squares(i).t_loc(2),'¤','Color',[0 0 0],'FontSize',20,'HorizontalAlignment','center','Visible','off');
				else
					squares(i).number = sum([squares(squares(i).adjInd).isMine]);
					if squares(i).number ~= 0
						for k = 1:(squares(i).number-size(numColors,1))
							numColors(k,1:3) = rand(1,3);
						end
						squares(i).numT = text(squares(i).t_loc(1),squares(i).t_loc(2), num2str(squares(i).number),'HorizontalAlignment','center','Color',numColors(squares(i).number,:),'FontSize',20,'Visible','off');
					end
				end
			end
		end
		
		function [squares, indGrid] = gridGen(nR,nC,maxSize)
			grid = reshape(1:nR*nC, [nR, nC]);
			indGrid = zeros(nR,nC);
			squares = square.empty;
			
			cur = 1;
			z = [0 1; 0 -1; 1 0; -1 0];
			while nnz(grid)~=0
				inds = nonzeros(grid);
				[r, c] = ind2sub(size(grid),inds(randi(length(inds))));
				rc = [r,c];
				grid(r,c) = 0;
				
				for i = 2:maxSize
					a = rc(randi(size(rc,1)),:) + z(randi(size(z,1)),:);
					if a(2)<=nC && a(1)<=nR && a(2)>0 && a(1)>0 && grid(a(1),a(2))~=0
						rc(size(rc,1)+1,:) = a;
						grid(a(1),a(2)) = 0;
					end
				end
				
				if size(rc,1)>1
					% 	get all the points
					v = zeros(size(rc,1)*4,2);
					for i = 1:size(rc,1)
						a = rc(i,:);
						indGrid(a(1),a(2)) = cur;
						v(((i-1)*4+1):(i*4),1:2) = [a; a+[0 1]; a+[1 1]; a+[1 0]];
					end

					% 	pick bottom left point
					d = sum(v.^2,2); % array of squared distances
					[~, j] = min(d);
					j = blob_fcn(v, j, rc);
					verts = zeros(length(j),2);
					for i = 1:length(j)
						verts(i,:) = v(j(i),:);
					end
				else
					verts = [rc; rc+[0 1]; rc+[1 1]; rc+[1 0]];
					indGrid(rc(1),rc(2)) = cur;
				end				
								
				squares(cur) = square(rc,verts); %x is col, y is row
				% will need to alter square definition
				cur = cur+1;
			end
			
			square.adjacents(squares, indGrid);
			
			function [ vInds ] = blob_fcn( rc, vInds, blob)
				%{
				look for the adjacent points
				-pick the one that fits in the rotation
				--rotation is 3 long to j(end-1)ent backtracking
				---this rotation is dependent on the angle of the vector formed by the last 2 points.
				------ 0 - d,r,u
				------90 - r,u,l
				-----180 - u,l,d
				-----270 - l,d,r
				-----the rotation is d,r,u,l shifted w/ one eliminated
				%}
				if length(vInds)==1 % first fcn call
					theta = 0;
				elseif vInds(1)==vInds(end)
					return
				else
					theta = atan2d(rc(vInds(end-1),1)-rc(vInds(end),1),rc(vInds(end),2)-rc(vInds(end-1),2)); % y is reversed to match reversed axis
				end
				switch theta
					case 0
						b = [1 0; 0 1; -1 0];
					case 90
						b = [0 1; -1 0; 0 -1];
					case 180
						b = [-1 0; 0 -1; 1 0];
					case -90
						b = [0 -1; 1 0; 0 1];
				end

				for k = 1:3
					nxtPt = b(k,:) + rc(vInds(end),:);
					for q = 1:size(rc,1)
				if all(rc(q,:)==nxtPt)
					good = false;
					if b(k,1)~=0 % vert line
						asd = min([nxtPt(1),rc(vInds(end),1)]);
						b1 = [asd,nxtPt(2)];
						b2 = [asd,nxtPt(2)-1];
					else %horiz line
						asd = min([nxtPt(2),rc(vInds(end),2)]);
						b1 = [nxtPt(1),asd];
						b2 = [nxtPt(1)-1,asd];
					end
					
					for w = 1:size(blob,1)
						if all(blob(w,:)== b1) || all(blob(w,:)==b2)
							good = true;
							break
						end
					end
					if good
						vInds = blob_fcn(rc,[vInds,q],blob);
						return
					end
				end
			end
% 					for k = 1:size(rc,1)
% 						if all(rc(k,:)==nxtPt)
% 							vInds = blob_fcn(rc,[vInds,k]);
% 							return
% 						end
% 					end
				end

			end
		end
	
	end
end





					% remove duplicates
% 					i = 1;
% 					while i<=size(v,1)
% 						j = i+1;
% 						while j<=size(v,1)
% 							if all(v(j,:)==v(i,:))
% 								v = [v(1:j-1,:);v(j+1:end,:)];
% 								j = j - 1;
% 							end
% 							j = j + 1;
% 						end
% 						i = i+1;
% 					end
