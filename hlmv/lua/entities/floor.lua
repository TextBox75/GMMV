AddCSLuaFile() 

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.ClassName = "mv_floor"

function ENT:UpdateAngles(Angle)
    Translation:SetAngles(Angle)
end

function ENT:UpdateScale(Scale)
    Translation:SetScale(Vector(1, 1, 1) * Scale)
end

function ENT:Initialize()
	local Size = 50
	self.Mesh = Mesh();
    self.MeshUnder = Mesh();
	local Top = {}

	--top left triangle 
	Top[1] = { pos = Vector(Size, -Size, 0), normal = Vector(0, 0, 1), u=0, v=0  }
	Top[2] = { pos = Vector(-Size, -Size, 0), normal = Vector(0, 0, 1), u=0, v=10  }
	Top[3] = { pos = Vector(-Size, Size, 0), normal = Vector(0, 0, 1), u=10, v=10  }
    --top right triangle
	Top[4] = { pos = Vector(-Size, Size, 0), normal = Vector(0, 0, 1), u=0, v=10  }
	Top[5] = { pos = Vector(Size, Size, 0), normal = Vector(0, 0, 1), u=10, v=10  }
	Top[6] = { pos = Vector(Size, -Size, 0), normal = Vector(0, 0, 1),  u=10, v=0  }

	self.Mesh:BuildFromTriangles(Top);

    Translation = Matrix()
    Translation:Translate(self:GetPos())
    Translation:SetAngles(Angle(0, 0, 0))
    Translation:SetScale(Vector(1, 1, 1) * 1)
end

function ENT:Draw()
    render.SetMaterial(Material("hlmv/floor"))
    cam.PushModelMatrix(Translation)
		self.Mesh:Draw();
	cam.PopModelMatrix();
end

scripted_ents.Register(ENT, "mv_floor")