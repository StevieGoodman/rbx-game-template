local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local SoundConfig = require(ReplicatedStorage.Config.Sounds)

export type SoundProperties = {
	SoundId: number,
	Name: string,
	Volume: number,
	RollOffMinDistance: number,
	RollOffMaxDistance: number,
	PlaybackSpeed: number,
	Looped: boolean,
	SoundGroup: SoundGroup,
	Parent: Instance,
}

local SoundPlayer = {}

function SoundPlayer.PlaySoundEffect(soundName: string, soundProperties: SoundProperties?): Sound
    assert(SoundConfig[soundName] ~= nil, `Cannot play sound effect "{soundName}" because it does not exist in SoundConfig`)
    soundProperties =
        if soundProperties == nil then SoundConfig[soundName]
        else TableUtil.Reconcile(soundProperties, SoundConfig[soundName])
    local sound = Instance.new("Sound")
    for propertyName, propertyValue in soundProperties do
        sound[propertyName] = propertyValue
    end
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    sound:Play()
    return sound
end

return SoundPlayer