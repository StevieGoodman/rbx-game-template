local serviceCount = 0

for _, child in script:GetDescendants() do
	if not child:IsA("ModuleScript") then continue end
	serviceCount += 1
	require(child)
end

print(`Successfully started {serviceCount} service(s)`)