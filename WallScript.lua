--[[
Author(s): Electra Bree & Aaron Spivey

Manages the movement of the wall outside the elevator - this creates the illusion that the elevator is falling
]]--

--// Configuration
studs_offset = 25 

--// Variables
run_service = game:GetService("RunService")
tweening_check = false

--// Moves the wall up
function tween_upwards()
    tweening_check = true
    if studs_offset ~= 0 then
        local CurrentOffset = 0
        while true and script.Stopped.Value == false do
			local inc = 0.3
            workspace.Wall:SetPrimaryPartCFrame(CFrame.new(workspace.Wall.PrimaryPart.CFrame.X, workspace.Wall.PrimaryPart.CFrame.Y + inc, workspace.Wall.PrimaryPart.CFrame.Z))
            CurrentOffset = CurrentOffset + inc
            if studs_offset > 0 then
                if CurrentOffset >= studs_offset then
                    break
                end
             elseif script.Stopped.Value == true then 
				break
            end
            run_service.Heartbeat:Wait()
        end
    end
    run_service.Heartbeat:Wait()
    workspace.Wall:SetPrimaryPartCFrame(workspace.Wall.PrimaryPart.CFrame)
    tweening_check = false
end

run_service.Heartbeat:Connect(function()
    if not tweening_check then
        tween_upwards()
	end
end)

spawn(function()
	while wait() do
		if script.Stopped.Value == true then 
			workspace.Wall.Parent = game.Lighting
			workspace.Elevator.Window.Brick.Transparency = 0
			workspace.Elevator.Window.Wall.Transparency = 0
		elseif script.Stopped.Value == false then 
			workspace.Wall.Parent = workspace
			workspace.Elevator.Window.Brick.Transparency = 1
			workspace.Elevator.Window.Wall.Transparency = 1
		end
	end
end)