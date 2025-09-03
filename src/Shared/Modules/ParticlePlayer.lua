local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local ParticleConfig = require(ReplicatedStorage.Shared.Config.Particles)

export type ParticleEmitterProperties = {
	Texture: string,
	Name: string,
    Acceleration: Vector3,
    Brightness: number,
    Color: ColorSequence,
    Drag: number,
    EmissionDirection: Enum.NormalId,
    Enabled: boolean,
    Lifetime: NumberRange,
    LightEmission: number,
    LightInfluence: number,
    LockedToPart: boolean,
	Rate: number,
	Size: NumberSequence,
	RotSpeed: NumberRange,
	Rotation: NumberRange,
    Shape: Enum.ParticleEmitterShape,
    ShapeInOut: Enum.ParticleEmitterShapeInOut,
    ShapePartial: number,
	Speed: NumberRange,
    SpreadAngle: Vector2,
	Squash: NumberSequence,
    TimeScale: number,
    Transparency: NumberSequence,
    VelocityInheritance: number,
    WindAffectsDrag: boolean,
	Parent: Instance,
}

local ParticlePlayer = {}

function ParticlePlayer.PlayParticleEffect(effectName: string, amount, emitterProperties: ParticleEmitterProperties?): Sound
    assert(ParticleConfig[effectName] ~= nil, `Cannot play particle effect "{effectName}" because it does not exist in ParticleConfig`)
    emitterProperties =
        if emitterProperties == nil then ParticleConfig[effectName]
        else TableUtil.Reconcile(emitterProperties, ParticleConfig[effectName])
    local emitter = Instance.new("ParticleEmitter")
    emitter.Enabled = false
    for propertyName, propertyValue in emitterProperties do
        emitter[propertyName] = propertyValue
    end
    emitter:Emit(amount)
    task.delay(emitter.Lifetime.Max, function()
        emitter:Destroy()
    end)
    return emitter
end

return ParticlePlayer