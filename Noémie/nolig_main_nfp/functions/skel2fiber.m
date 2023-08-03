function [fiber, extremities, regFib] = skel2fiber(bwfilt_agg, perim, skel, skel_coor, ends_coor)
% Processing step to be improved in the near future !!
% This function extends the given skel so it reaches the aggregate boundaries to get full fiber and its length
%
% At each end, function uses direction vector from preceding skel point to endpoint and adds it 
% iteratively until it reaches agg perimeter in a X-connected environment 


% get skeleton length
skel_length = sum(skel,"all");

% get fiber
fiber = skel;
arsz = size(fiber); % array size
regFib = true;

% get dimension 
if length(arsz) == 2
    dimension = '2D';
elseif length(arsz) == 3
    dimension = '3D';
end

% get fiber according to skel dimension 
switch dimension
    %% 2D
    case '2D'
        extremities = zeros([2,2]);
        for e = 1:2
            % find closest skel point for each endpoint
            ptdist = [0,0,500]; % [y x dist]
            endpoint = ends_coor(e,:); %[ro_e(e), co_e(e)];
            for p = 1:skel_length
                point = skel_coor(p,:);
                if sum(point == endpoint) == 2
                    continue
                end
                dist = sqrt( ((point(2)-endpoint(2))^2) + ((point(1)-endpoint(1))^2) );
                % save dist if smaller than previous ones
                if dist < ptdist(3) 
                    ptdist = [point, dist];
                end
            end
            
            % from endpoint, reach aggregate boundary while getting fiber 
            prev_pt = ptdist(1:2); % previous point
            dirVec = endpoint - prev_pt ; % directional vector from prev point to endpoint
            reachpoint = endpoint; 
            reach = 0;
            
            % get boundary point
            while reach ~= 1 
        
                reach = 1;
        
                if perim(reachpoint(1),reachpoint(2)) == 1 
                    bdpoint = reachpoint;
                    break
                else
                    fiber(reachpoint(1),reachpoint(2)) = 1; % set added skel values to 1
                    reach = 0;
                    % stop dirVec in directions that will exceed array size 
                    if any(reachpoint == arsz)
                        dim = find(reachpoint == arsz);
                        dirVec(dim) = 0;
                    end 
                    for j = 1:2
                        if reachpoint(j) == 1 & dirVec(j) < 0
                            dirVec(j) = 0;
                        end
                    end
                    if (dirVec == [0, 0]) % to avoid infinite loops
                        reach = 0;
                        break
                    end
                    
                    % go to next step if next point is outside aggregate 
                    if bwfilt_agg(round(reachpoint+dirVec)) == 0 
                        reach = 0;
                        break
                    end
        
                    % add dir vector to reachpoint
                    reachpoint = round(reachpoint + dirVec);
        
                end
          
            end
        
            % if not found in vector direction, test around reachpoint if perim is reached
            if reach == 0
                % reset dirVec
                dirVec = endpoint - prev_pt ; 
        
                while reach ~= 1
        
                    reach = 1;
                
                    %% 4 connexion 
                    if reachpoint(1) <  arsz(1) & perim(reachpoint(1)+1,reachpoint(2)) == 1 
                        bdpoint = [reachpoint(1)+1,reachpoint(2)];
                        break
        
                    elseif reachpoint(1) >= 2 & perim(reachpoint(1)-1,reachpoint(2)) == 1
                        bdpoint = [reachpoint(1)-1,reachpoint(2)];
                        break
            
                    elseif reachpoint(2) < arsz(2) & perim(reachpoint(1),reachpoint(2)+1) == 1
                        bdpoint = [reachpoint(1),reachpoint(2)+1];
                        break
            
                    elseif reachpoint(2) >= 2 & perim(reachpoint(1),reachpoint(2)-1) == 1
                        bdpoint = [reachpoint(1),reachpoint(2)-1];
                        break
           
                
                    %% 8 connexion
               
                    elseif reachpoint(1) >= 2 & reachpoint(2) >= 2 & perim(reachpoint(1)-1, reachpoint(2)-1) == 1
                        bdpoint = [reachpoint(1)-1,reachpoint(2)-1];
                        break
            
                    elseif reachpoint(1) >= 2 & reachpoint(2) < arsz(2) & perim(reachpoint(1)-1, reachpoint(2)+1) == 1
                        bdpoint = [reachpoint(1)-1,reachpoint(2)+1];
                        break
            
                    elseif reachpoint(1) < arsz(1) & reachpoint(2) < arsz(2) & perim(reachpoint(1)+1, reachpoint(2)+1) == 1
                        bdpoint = [reachpoint(1)+1,reachpoint(2)+1];
                        break
                     
                    elseif reachpoint(1) < arsz(1) & reachpoint(2) >= 2 & perim(reachpoint(1)+1, reachpoint(2)-1) == 1
                        bdpoint = [reachpoint(1)+1,reachpoint(2)-1];
                        break
        
        
                    %% continue searching
                    else
                        fiber(reachpoint(1),reachpoint(2)) = 1; % set added skel values to 1
                        reach = 0;
                        % stop dirVec in directions that will exceed array size 
                        if any(reachpoint == arsz)
                            dim = find(reachpoint == arsz);
                            dirVec(dim) = 0;
                        end 
                        for f = 1:2
                            if reachpoint(f) == 1 & dirVec(f) < 0
                                dirVec(f) = 0;
                            end
                        end
                        if (dirVec == [0, 0]) % to avoid infinite loops
                            bdpoint = [0,0];
                            regFib = false; % wasnt able to extend skel correctly
                            break
                        end
            
                        % add dir vector to reachpoint
                        reachpoint = round(reachpoint + dirVec);
                    end 
                end
        
            end

            % save new endpoints 
            fiber(reachpoint(1),reachpoint(2)) = 1;
            if sum(bdpoint) ~= 0
                fiber(bdpoint(1),bdpoint(2)) = 1;
            end
            extremities(e,:) = bdpoint;
        end

    %% 3D
    case '3D'

        extremities = zeros([2,3]);
        for e = 1:2
            % find closest skel point for each endpoint
            ptdist = [0,0,0,500]; % [y x z dist]
            endpoint = ends_coor(e,:); %[ro_e(e), co_e(e), pl_e(e)];
            for p = 1:skel_length
                point = skel_coor(p,:);
                if sum(point == endpoint) == 3
                    continue
                end
                dist = sqrt( ((point(2)-endpoint(2))^2) + ((point(1)-endpoint(1))^2) + ((point(3)-endpoint(3))^2));
                % save dist if smaller than previous ones
                if dist < ptdist(4) 
                    ptdist = [point, dist];
                end
            end
            
            % from endpoint, reach aggregate boundary while getting fiber 
            prev_pt = ptdist(1:3); % previous point
            dirVec = endpoint - prev_pt ; % directional vector from prev point to endpoint
            reachpoint = endpoint; 
            reach = 0;
            
        
            % get boundary point
            while reach ~= 1 
        
                reach = 1;
        
                if perim(reachpoint(1),reachpoint(2),reachpoint(3)) == 1 
                    bdpoint = reachpoint;
                    break
                else
                    fiber(reachpoint(1),reachpoint(2), reachpoint(3)) = 1; % set added skel values to 1
                    reach = 0;
                    % stop dirVec in directions that will exceed array size 
                    if any(reachpoint == arsz)
                        dim = find(reachpoint == arsz);
                        dirVec(dim) = 0;
                    end 
                    for r = 1:3
                        if reachpoint(r) == 1 & dirVec(r) < 0
                            dirVec(r) = 0;
                        end
                    end
                    if (dirVec == [0, 0, 0]) % to avoid infinite loops
                        reach = 0;
                        break
                    end
                    
                    % go to next step if next point is outside aggregate 
                    if bwfilt_agg(round(reachpoint+dirVec)) == 0 
                        reach = 0;
                        break
                    end
        
                    % add dir vector to reachpoint
                    reachpoint = round(reachpoint + dirVec);
        
                end
          
            end
        
            % if not found in vector direction, test around reachpoint if perim is reached
            if reach == 0
                % reset dirVec
                dirVec = endpoint - prev_pt ; 
        
                while reach ~= 1
        
                    reach = 1;
                
                    %% 6 connexion 
                    if reachpoint(1) <  arsz(1) & perim(reachpoint(1)+1,reachpoint(2),reachpoint(3)) == 1 
                        bdpoint = [reachpoint(1)+1,reachpoint(2),reachpoint(3)];
                        break
        
                    elseif reachpoint(1) >= 2 & perim(reachpoint(1)-1,reachpoint(2),reachpoint(3)) == 1
                        bdpoint = [reachpoint(1)-1,reachpoint(2),reachpoint(3)];
                        break
            
                    elseif reachpoint(2) < arsz(2) & perim(reachpoint(1),reachpoint(2)+1,reachpoint(3)) == 1
                        bdpoint = [reachpoint(1),reachpoint(2)+1,reachpoint(3)];
                        break
            
                    elseif reachpoint(2) >= 2 & perim(reachpoint(1),reachpoint(2)-1,reachpoint(3)) == 1
                        bdpoint = [reachpoint(1),reachpoint(2)-1,reachpoint(3)];
                        break
            
                    elseif reachpoint(3) < arsz(3) & perim(reachpoint(1),reachpoint(2),reachpoint(3)+1) == 1
                        bdpoint = [reachpoint(1),reachpoint(2),reachpoint(3)+1];
                        break
                        
                    elseif reachpoint(3) >= 2 & perim(reachpoint(1),reachpoint(2),reachpoint(3)-1) == 1
                        bdpoint = [reachpoint(1),reachpoint(2),reachpoint(3)-1];
                        break
                
                    %% 18 connexion
                    
                    
                    % corners on same xz plane 
                    elseif reachpoint(2) >= 2 & reachpoint(3) >= 2 & perim(reachpoint(1), reachpoint(2)-1, reachpoint(3)-1) == 1
                        bdpoint = [reachpoint(1),reachpoint(2)-1,reachpoint(3)-1];
                        break
            
                    elseif reachpoint(2) >= 2 & reachpoint(3) < arsz(3) & perim(reachpoint(1), reachpoint(2)-1, reachpoint(3)+1) == 1
                        bdpoint = [reachpoint(1),reachpoint(2)-1,reachpoint(3)+1];
                        break
            
                    elseif reachpoint(2) < arsz(2) & reachpoint(3) < arsz(3) & perim(reachpoint(1), reachpoint(2)+1, reachpoint(3)+1) == 1
                        bdpoint = [reachpoint(1),reachpoint(2)+1,reachpoint(3)+1];
                        break
                     
                    elseif reachpoint(2) < arsz(2) & reachpoint(3) >= 2 & perim(reachpoint(1), reachpoint(2)+1, reachpoint(3)-1) == 1
                        bdpoint = [reachpoint(1),reachpoint(2)+1,reachpoint(3)-1];
                        break
            
                        
                    % corners on same yz plane
                    elseif reachpoint(1) >= 2 & reachpoint(3) >= 2 & perim(reachpoint(1)-1, reachpoint(2), reachpoint(3)-1) == 1
                        bdpoint = [reachpoint(1)-1,reachpoint(2),reachpoint(3)-1];
                        break
            
                    elseif reachpoint(1) >= 2 & reachpoint(3) < arsz(3) & perim(reachpoint(1)-1, reachpoint(2), reachpoint(3)+1) == 1
                        bdpoint = [reachpoint(1)-1,reachpoint(2),reachpoint(3)+1];
                        break
            
                    elseif reachpoint(1) < arsz(1) & reachpoint(3) < arsz(3) & perim(reachpoint(1)+1, reachpoint(2), reachpoint(3)+1) == 1
                        bdpoint = [reachpoint(1)+1,reachpoint(2),reachpoint(3)+1];
                        break
                     
                    elseif reachpoint(1) < arsz(1) & reachpoint(3) >= 2 & perim(reachpoint(1)+1, reachpoint(2), reachpoint(3)-1) == 1
                        bdpoint = [reachpoint(1)+1,reachpoint(2),reachpoint(3)-1];
                        break
            
            
                    % corners on same xy plane 
                    elseif reachpoint(1) >= 2 & reachpoint(2) >= 2 & perim(reachpoint(1)-1, reachpoint(2)-1, reachpoint(3)) == 1
                        bdpoint = [reachpoint(1)-1,reachpoint(2)-1,reachpoint(3)];
                        break
            
                    elseif reachpoint(1) >= 2 & reachpoint(2) < arsz(2) & perim(reachpoint(1)-1, reachpoint(2)+1, reachpoint(3)) == 1
                        bdpoint = [reachpoint(1)-1,reachpoint(2)+1,reachpoint(3)];
                        break
            
                    elseif reachpoint(1) < arsz(1) & reachpoint(2) < arsz(2) & perim(reachpoint(1)+1, reachpoint(2)+1, reachpoint(3)) == 1
                        bdpoint = [reachpoint(1)+1,reachpoint(2)+1,reachpoint(3)];
                        break
                     
                    elseif reachpoint(1) < arsz(1) & reachpoint(2) >= 2 & perim(reachpoint(1)+1, reachpoint(2)-1, reachpoint(3)) == 1
                        bdpoint = [reachpoint(1)+1,reachpoint(2)-1,reachpoint(3)];
                        break
        
        
                    %% continue searching
                    else
                        fiber(reachpoint(1),reachpoint(2), reachpoint(3)) = 1; % set added skel values to 1
                        reach = 0;
                        % stop dirVec in directions that will exceed array size 
                        if any(reachpoint == arsz)
                            dim = find(reachpoint == arsz);
                            dirVec(dim) = 0;
                        end 
                        for v = 1:3
                            if reachpoint(v) == 1 & dirVec(v) < 0
                                dirVec(v) = 0;
                            end
                        end
                        if (dirVec == [0, 0, 0]) % to avoid infinite loops
                            bdpoint = [0,0,0];
                            regFib = false; % wasnt able to extend skel correctly
                            break
                        end
            
                        % add dir vector to reachpoint
                        reachpoint = round(reachpoint + dirVec);
                    end 
                end
        
            end
            % save new endpoints 
            fiber(reachpoint(1),reachpoint(2), reachpoint(3)) = 1;
            if sum(bdpoint) ~= 0
                fiber(bdpoint(1),bdpoint(2), bdpoint(3)) = 1;
            end
            extremities(e,:) = bdpoint;
        end

end


end