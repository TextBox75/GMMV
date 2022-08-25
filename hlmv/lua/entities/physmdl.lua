AddCSLuaFile() -- This line is necessary to make this entire script work, I assume it's an indirect method of linking stuff between lua files, whilst include() is a direct link between different lua files.
-- Gmod networking is a living nightmare.

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.ClassName = "PhysMDL"

function ENT:SetEnt(Ent)
    MVEnt = Ent
    MVEnt:PhysicsInit(SOLID_VPHYSICS)
end

function ENT:UpdateAngles(Angle)
    Translation:SetAngles(Angle)
end

function ENT:UpdateScale(Scale)
    Translation:SetScale(Vector(1, 1, 1) * Scale)
end

function ENT:Initialize()
    local PhysObj = MVEnt:GetPhysicsObject()
    if IsValid(PhysObj) then
        self.Mesh = Mesh()
        self.Mesh:BuildFromTriangles(PhysObj:GetMesh())
        Translation = Matrix()
        Translation:Translate(self:GetPos())
        Translation:SetAngles(Angle(0, 0, 0))
        Translation:SetScale(Vector(1, 1, 1) * 1)
    end
end

function ENT:Draw()
    render.SetMaterial(Material("editor/wireframe"))
    cam.PushModelMatrix(Translation);
		self.Mesh:Draw();
	cam.PopModelMatrix();
    -- NOTE: To enable wireframe on a model, you must set it's material to "editor/wireframe"
end

scripted_ents.Register(ENT, "PhysMDL")