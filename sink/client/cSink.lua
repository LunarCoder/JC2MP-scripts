class "ClientSink"

function ClientSink:__init()
    self.sinking = false
    self.boats = {5, 6, 16, 19, 25, 27, 28, 38, 45, 50, 53, 69, 80, 88}
    Events:Subscribe("LocalPlayerExitVehicle", self, self.vExit)
    Events:Subscribe("LocalPlayerEjectVehicle", self, self.eject)
    Events:Subscribe("PreTick", self, self.tick)
    Events:Subscribe("LocalPlayerChat", self, self.localPlayerChat)
end

function ClientSink:eject()
    if not self.v then return end
    if not self.v:GetDriver() == LocalPlayer then return end
    Network:Send("BoatSank", self.v)
    self.sinking = false
end

function ClientSink:vExit(args)
    if not self.v then return end
    Network:Send("BoatSank", self.v)
    self.sinking = false
end

function ClientSink:localPlayerChat(args)
    if args.text == "/sink" then
        local v = LocalPlayer:GetVehicle()
        if not v then Chat:Print("You are not in a boat!", Color.Yellow) return false end
        if v:GetPosition().y > 202 then Chat:Print("You are not in water!", Color.Yellow) return false end
        for k,val in pairs(self.boats) do
            if v:GetModelId() == val then
                self.sinking = true
                Network:Send("BoatSinking", v:GetPosition())
            end
        end
        if not self.sinking then Chat:Print("You are not in a boat!", Color.Yellow) return false end
    end
end

function ClientSink:tick()
    if not self.sinking then return end
    self.v = LocalPlayer:GetVehicle()
    if not self.v then return end
    local height = Physics:GetTerrainHeight(self.v:GetPosition())+2
    local vHeight = self.v:GetPosition().y
    if vHeight <= height then
        self.sinking = false
        Network:Send("BoatSank")
        return
    end
    self.v:SetLinearVelocity(Vector3.Down * 1.8)
end

clientSink = ClientSink()