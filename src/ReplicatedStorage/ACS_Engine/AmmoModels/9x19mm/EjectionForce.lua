local EjectionForce = {}

-- Force direction
function EjectionForce.CalculateForce()
	return Vector3.new(
		math.random(95,135) / 10, -- Side to side
		math.random(45,55) / 10, -- Up
		-math.random(75,85) / 10 -- Front
	)
end

-- Shell physical properties
EjectionForce.PhysProperties = PhysicalProperties.new(
	10, -- Density
	2, -- Friction
	0.1, -- Elasticity
	1, -- FrictionWeight
	1 -- ElasticityWeight
)

-- Force attachment
EjectionForce.ForcePoint = Vector3.new(
	0,0,0
)

return EjectionForce
