class "ServerSink"

function ServerSink:__init()
    self.boats = {}
    Events:Subscribe("PreTick", self, self.tick)
    Network:Subscribe("BoatSank", self, self.boatSank)
    Network:Subscribe("BoatSinking", self, self.boatSinking)
end

function ServerSink:boatSank(args, player)
    if player:GetVehicle() then
        self.boats[player:GetVehicle():GetId()] = Timer()
    else
        self.boats[args:GetId()] = Timer()
    end
end

function ServerSink:boatSinking(pos, player)
    local pos = player:GetVehicle():GetPosition()
    Chat:Broadcast(player:GetName().."'s boat is sinking! Last known position: "..string.format("%i, %i", pos.x, pos.z), Color.White)
end

function ServerSink:tick()
    for k,v in pairs(self.boats) do
        t = self.boats[k]
        if t:GetSeconds() < 30 then
            local veh = Vehicle.GetById(k)
            if IsValid(veh) then
                veh:SetLinearVelocity(Vector3.Down*1.5)
            end
        else
            local veh = Vehicle.GetById(k)
            if IsValid(veh) then
                self.boats[k] = nil
                veh:Remove()
            end
        end
    end
end
serverSink = ServerSink()