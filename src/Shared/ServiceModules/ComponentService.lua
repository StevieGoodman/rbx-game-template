local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Trove = require(ReplicatedStorage.Packages.Trove)

local ComponentService = {}

local function ConstructComponent(service, instance)
	local component = {
		Instance = instance,
		Trove = Trove.new(),
	}
	service.Components[instance] = component
	if service.Construct == nil then return end
	service.Construct(component)
end

local function DestroyComponent(service, instance)
    local component = service.Components[instance]
    if component == nil then return end
    if service.Stop ~= nil then
        service.Stop(component)
    end
    component.Trove:Destroy()
    service.Components[instance] = nil
end

local function BindCallbacks(service, tag)
    for _, instance in CollectionService:GetTagged(tag) do
		ConstructComponent(service, instance)
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		ConstructComponent(service, instance)
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
		DestroyComponent(service, instance)
	end)
	if service.PreRender ~= nil then
		assert(RunService:IsClient(), `Cannot bind PreRender callback in non-client context!`)
		RunService.PreRender:Connect(function(deltaTime)
			for _, component in service.Components do
				service.PreRender(component)
			end
		end)
	end
	if service.PreAnimation ~= nil then
		RunService.PreAnimation:Connect(function(deltaTime)
			for _, component in service.Components do
				service.PreAnimation(component)
			end
		end)
	end
	if service.PreSimulation ~= nil then
		RunService.PreSimulation:Connect(function(deltaTime)
			for _, component in service.Components do
				service.PreSimulation(component)
			end
		end)
	end
	if service.PostSimulation ~= nil then
		RunService.PostSimulation:Connect(function(deltaTime)
			for _, component in service.Components do
				service.PostSimulation(component)
			end
		end)
	end
	if service.Heartbeat ~= nil then
		RunService.Heartbeat:Connect(function(deltaTime)
			for _, component in service.Components do
				service.Heartbeat(component)
			end
		end)
	end
end

local function StartService(service)
    if service.Create ~= nil and not service.Created then
        service.Start()
    end
    service.Started = true
end

function ComponentService.new(service, tag)
	service.Components = {}
    BindCallbacks(service, tag)
	StartService(service)
	return service
end

return ComponentService