local RunService = game:GetService("RunService")

local SingletonService = {}

local function BindCallbacks(service)
    if service.PreRender ~= nil then
        assert(RunService:IsClient(), `Cannot bind PreRender callback in non-client context!`)
        RunService.PreRender:Connect(function(deltaTime)
            service.PreRender(deltaTime)
        end)
    end
    if service.PreAnimation ~= nil then
        RunService.PreAnimation:Connect(function(deltaTime)
            service.PreAnimation(deltaTime)
        end)
    end
    if service.PreSimulation ~= nil then
        RunService.PreSimulation:Connect(function(deltaTime)
            service.PreSimulation(deltaTime)
        end)
    end
    if service.PostSimulation ~= nil then
        RunService.PostSimulation:Connect(function(deltaTime)
            service.PostSimulation(deltaTime)
        end)
    end
    if service.Heartbeat ~= nil then
        RunService.Heartbeat:Connect(function(deltaTime)
            service.Heartbeat(deltaTime)
        end)
    end
end

local function StartService(service)
    if service.Create ~= nil and not service.Created then
        service.Start()
    end
    service.Started = true
end

function SingletonService.new(service)
	BindCallbacks(service)
	StartService(service)
	return service
end

return SingletonService