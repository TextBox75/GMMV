if CLIENT then
    surface.SetFont("DermaDefault")
    MVInfo = 
    {
        SizeX = ScrW() * 1000 / 1280,
        SizeY = ScrH() * 700 / 720,
        ModelAngle = Angle(0, 180, 0),
        IsLeftDragging = false,
        IsRightDragging = false,
        IsMiddleDragging = false,
        PreviousX = 0,
        PreviousY = 0,
        TotalXDelta = 0,
        TotalYDelta = 0,
        Bones = {},
        Attachments = {},
        HitboxSet = {}
    }

    MVInfo.X = ScrW() / 2 - MVInfo.SizeX / 2
    MVInfo.Y = ScrH() / 2 - MVInfo.SizeY / 2

    properties.Add("open_mv", 
    {
        MenuLabel = "Open in Model Viewer",
        MenuIcon = "icon16/page.png",
        Order = 90001,
    
        Filter = function( self, ent, ply )
            if not IsValid(ent) then return false end
            return true
        end,
    
        Action = function( self, ent )
            CreateWindow(ent)
        end,
    })

    -- //////////////////////////////////////// MAIN ////////////////////////////////////////

    function CreateWindow(ent)
        surface.SetFont("DermaDefault")
        if ent:IsValid() then
            Window = vgui.Create( "DFrame" )
            Window:SetPos( MVInfo.X, MVInfo.Y) 
            Window:SetSize( MVInfo.SizeX, MVInfo.SizeY) 
            Window:SetTitle("Model Viewer")
            Window:SetDraggable( true ) 
            Window:ShowCloseButton( true ) 
            Window:MakePopup()
        
            Viewport = vgui.Create("DPanel", Window)
            Viewport:SetSize(MVInfo.SizeX * 0.48, MVInfo.SizeY * 0.9)
            Viewport:Center()
            Viewport:SetBackgroundColor(Color(50, 50, 50, 255))
            Viewport:SetX(Window:GetWide() / 2 + 5)
    
            ModelPanel = vgui.Create("DModelPanel", Viewport)
            if ( ent:GetClass() == "prop_effect" ) then
                ModelPanel:SetModel(ent.AttachedEntity:GetModel())
            else
                ModelPanel:SetModel(ent:GetModel())
            end
            ModelPanel:GetEntity():SetAngles(MVInfo.ModelAngle)
            ModelPanel:SetPos(0, 0)
            ModelPanel:SetSize(Viewport:GetWide(), Viewport:GetTall())
            ModelPanel:SetLookAng(Angle(0, 0, 0))
            Min, Max = ModelPanel:GetEntity():GetModelBounds()
            ModelPanel:SetCamPos(Vector(-100, 0, Max.z / 2))
            ModelPanel.Entity:SetAngles(Angle(0, 180, 0))
            ModelPanel:MoveToFront()
    
            BGProperties = vgui.Create("DPanel", Window)
            BGProperties:SetSize(MVInfo.SizeX * 0.48, MVInfo.SizeY * 0.9)
            BGProperties:CenterVertical()
            BGProperties:SetX((Window:GetWide()) - (Viewport:GetX() + Viewport:GetWide()))

            PropertiesPanel = vgui.Create("DScrollPanel", BGProperties)
            PropertiesPanel:SetSize(BGProperties:GetWide(), BGProperties:GetTall())
            PropertiesPanel:SetPos(0, 0)
    
            IntroductionLabel = PropertiesPanel:Add("DLabel")
            IntroductionLabel:SetSize(BGProperties:GetWide(), BGProperties:GetTall() * 0.1)
            IntroductionLabel:SetFont("DermaDefault")
            IntroductionLabel:SetText("GMMV, Garry's Mod Model Viewer")
            IntroductionLabel:SetX(BGProperties:GetWide() / 2 - surface.GetTextSize(IntroductionLabel:GetText()) / 2)
            IntroductionLabel:SetY(0)
            IntroductionLabel:SetColor(Color(0, 0, 0, 255))

            ResetCameraButton = PropertiesPanel:Add("DButton")
            ResetCameraButton:SetSize(BGProperties:GetWide() * 0.8, BGProperties:GetTall() * 0.05)
            ResetCameraButton:SetPos(BGProperties:GetWide() / 2 - ResetCameraButton:GetWide() / 2, BGProperties:GetTall() * 0.1)
            ResetCameraButton:SetText("Reset Camera")
            ResetCameraButton.DoClick = function()
                ModelPanel:SetLookAng(Angle(0, 0, 0))
                ModelPanel:SetCamPos(Vector(-100, 0, Max.z / 2))
                MVInfo.ModelAngle = Angle(0, 180, 0)
                ModelPanel.Entity:SetAngles(Angle(0, 180, 0))
            end
    
            SequencesLabel = PropertiesPanel:Add("DLabel")
            SequencesLabel:SetSize(BGProperties:GetWide(), BGProperties:GetTall() * 0.02)
            SequencesLabel:SetFont("DermaDefault")
            SequencesLabel:SetText("Sequence")
            SequencesLabel:SetPos(BGProperties:GetWide() * 0.04, BGProperties:GetTall() * 0.2)
            SequencesLabel:SetColor(Color(0, 0, 0, 255))
    
            SequenceList = PropertiesPanel:Add("DComboBox")
            SequenceList:SetSize(BGProperties:GetWide() * 0.5, BGProperties:GetTall() * 0.03)
            SequenceList:SetPos(SequencesLabel:GetX() + BGProperties:GetWide() * 0.13,  SequencesLabel:GetY())
    
            local Sequences = ent:GetSequenceList()
            SequenceList:SetValue(Sequences[0])
            ModelPanel.Entity:SetCycle(0)
            ModelPanel.Entity:SetSequence(Sequences[0])
            ModelPanel.Entity:ResetSequence(Sequences[0])
            for k, v in pairs(Sequences) do
                SequenceList:AddChoice(v)
            end
    
            PlaybackSlider = PropertiesPanel:Add("DNumSlider")
            PlaybackSlider:SetSize(BGProperties:GetWide() * 0.9, BGProperties:GetTall() * 0.02)
            PlaybackSlider:SetPos(SequencesLabel:GetX(),  SequencesLabel:GetY() + SequencesLabel:GetTall() + BGProperties:GetTall() * 0.04)
            PlaybackSlider:SetDark(true)
            PlaybackSlider:SetText("Playback Rate")
            PlaybackSlider:SetValue(1)
            PlaybackSlider:SetMin(0)
            PlaybackSlider:SetMax(1)
    
            SkinLabel = PropertiesPanel:Add("DLabel")
            SkinLabel:SetSize(BGProperties:GetWide(), BGProperties:GetTall() * 0.02)
            SkinLabel:SetFont("DermaDefault")
            SkinLabel:SetText("Skin")
            local Offset = PlaybackSlider:GetY() - SequencesLabel:GetY()
            SkinLabel:SetPos(SequencesLabel:GetX(), PlaybackSlider:GetY() + Offset)
            SkinLabel:SetColor(Color(0, 0, 0, 255))
    
            SkinList = PropertiesPanel:Add("DComboBox")
            SkinList:SetSize(BGProperties:GetWide() * 0.5, BGProperties:GetTall() * 0.03)
            SkinList:SetPos(SequencesLabel:GetX() + BGProperties:GetWide() * 0.13, SkinLabel:GetY())
    
            SkinList:SetValue("Skin " .. ent:GetSkin())
            for i = 0, ent:SkinCount() - 1 do
                SkinList:AddChoice("Skin " .. i)
            end 
    
            BonesCheckBox = PropertiesPanel:Add("DCheckBoxLabel")
            BonesCheckBox:SetSize(BGProperties:GetWide() * 0.1 , BGProperties:GetTall() * 0.1)
            BonesCheckBox:SetText("Draw Bones")
            BonesCheckBox:SetPos(SequencesLabel:GetX(), SkinLabel:GetY() + Offset)
            BonesCheckBox:SetDark(true)
    
            AttachmentsCheckBox = PropertiesPanel:Add("DCheckBoxLabel")
            AttachmentsCheckBox:SetSize(BonesCheckBox:GetWide(), BonesCheckBox:GetTall())
            AttachmentsCheckBox:SetText("Draw Attachments")
            AttachmentsCheckBox:SetPos(SequencesLabel:GetX(), BonesCheckBox:GetY() + Offset)
            AttachmentsCheckBox:SetDark(true)
    
            DrawCollisionModelCheckBox = PropertiesPanel:Add("DCheckBoxLabel")
            DrawCollisionModelCheckBox:SetSize(BonesCheckBox:GetWide(), BonesCheckBox:GetTall())
            DrawCollisionModelCheckBox:SetText("Draw Collision Model")
            DrawCollisionModelCheckBox:SetPos(SequencesLabel:GetX(), AttachmentsCheckBox:GetY() + Offset)
            DrawCollisionModelCheckBox:SetDark(true)
    
            WireframeCheckBox = PropertiesPanel:Add("DCheckBoxLabel")
            WireframeCheckBox:SetSize(BonesCheckBox:GetWide(), BonesCheckBox:GetTall())
            WireframeCheckBox:SetText("Wireframe")
            WireframeCheckBox:SetPos(SequencesLabel:GetX(), DrawCollisionModelCheckBox:GetY() + Offset)
            WireframeCheckBox:SetDark(true)
    
            FloorCheckBox = PropertiesPanel:Add("DCheckBoxLabel")
            FloorCheckBox:SetSize(BonesCheckBox:GetWide(), BonesCheckBox:GetTall())
            FloorCheckBox:SetText("Draw Floor")
            FloorCheckBox:SetPos(SequencesLabel:GetX(), WireframeCheckBox:GetY() + Offset)
            FloorCheckBox:SetDark(true)
            FloorCheckBox:OnChange()
    
            BackgroundCheckBox = PropertiesPanel:Add("DCheckBoxLabel")
            BackgroundCheckBox:SetSize(BonesCheckBox:GetWide(), BonesCheckBox:GetTall())
            BackgroundCheckBox:SetText("Draw Background")
            BackgroundCheckBox:SetPos(SequencesLabel:GetX(), FloorCheckBox:GetY() + Offset)
            BackgroundCheckBox:SetDark(true)
    
            HitboxCheckBox = PropertiesPanel:Add("DCheckBoxLabel")
            HitboxCheckBox:SetSize(BonesCheckBox:GetWide(), BonesCheckBox:GetTall())
            HitboxCheckBox:SetText("Draw Hitboxes")
            HitboxCheckBox:SetPos(SequencesLabel:GetX(), BackgroundCheckBox:GetY() + Offset)
            HitboxCheckBox:SetDark(true)

            BBoxCheckbox = PropertiesPanel:Add("DCheckBoxLabel")
            BBoxCheckbox:SetSize(BonesCheckBox:GetWide(), BonesCheckBox:GetTall())
            BBoxCheckbox:SetText("Draw Bounding Box")
            BBoxCheckbox:SetPos(SequencesLabel:GetX(), HitboxCheckBox:GetY() + Offset)
            BBoxCheckbox:SetDark(true)

            AmbientColorMixer = PropertiesPanel:Add("DColorMixer")
            AmbientColorMixer:SetSize(BGProperties:GetWide() * 0.5, BGProperties:GetTall() * 0.3)
            AmbientColorMixer:SetPos(SequencesLabel:GetX(), BBoxCheckbox:GetY() + Offset)
            AmbientColorMixer:SetLabel("Ambient Light Color")
            AmbientColorMixer:SetColor(ModelPanel:GetAmbientLight())
    
            MaterialsList = PropertiesPanel:Add("DListView")
            MaterialsList:SetSize(BGProperties:GetWide() * 0.8, BGProperties:GetTall() * 0.2)
            MaterialsList:SetX(SequencesLabel:GetX())
            MaterialsList:SetY(AmbientColorMixer:GetY() + Offset * 6)
            MaterialsList:AddColumn("Materials Loaded")
            for k, v in pairs(ent:GetMaterials()) do
                MaterialsList:AddLine(v)
            end 

            BodygroupProperties = PropertiesPanel:Add("DProperties")
            BodygroupProperties:SetSize(BGProperties:GetWide() * 0.8, BGProperties:GetTall() * 0.15)
            BodygroupProperties:SetPos(HitboxCheckBox:GetX(), MaterialsList:GetY() + MaterialsList:GetTall() + Offset)
            local TotalBDGroups = 0
            local Groups = 0
            for k, v in pairs(ent:GetBodyGroups()) do
                Groups = Groups + 1
                TotalBDGroups = TotalBDGroups + ent:GetBodygroupCount(k)
                Rows = k
                local BDGroupRow = BodygroupProperties:CreateRow("Bodygroups", v.name)
                BDGroupRow:Setup("Int", { min = 0, max = v.num - 1 } )
                BDGroupRow:SetValue(0)
                function BDGroupRow:DataChanged(any)
                    ModelPanel.Entity:SetBodygroup(k - 1, any)
                end
            end
            for i = 0, ent:GetFlexNum() - 1 do
                local FlexRow = BodygroupProperties:CreateRow("Flexbones", ent:GetFlexName(i))
                FlexRow:Setup("Float", { min = 0, max = 1 } )
                FlexRow:SetValue(0)
                function FlexRow:DataChanged(any)
                    ModelPanel.Entity:SetFlexWeight(i, any)
                end
            end

            AnotherEmptySpaceLabel = PropertiesPanel:Add("DLabel")
            AnotherEmptySpaceLabel:SetSize(BGProperties:GetWide(), BGProperties:GetTall() * 0.02)
            AnotherEmptySpaceLabel:SetFont("DermaDefault")
            AnotherEmptySpaceLabel:SetText("")
            AnotherEmptySpaceLabel:SetPos(SequencesLabel:GetX(), BodygroupProperties:GetY() + BodygroupProperties:GetCanvas():GetTall() + Offset * 3)
            AnotherEmptySpaceLabel:SetColor(Color(0, 0, 0, 255))
  
            //////////////////////////////// LABELS /////////////////////////////////////////////
    
            ModelnameLabel = vgui.Create("DLabel", ModelPanel)
            ModelnameLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            ModelnameLabel:SetPos(ModelPanel:GetWide() * 0.01, 0)
            ModelnameLabel:SetText(ent:GetModel())
            ModelnameLabel:SetFont("DermaDefault")
            ModelnameLabel:SetColor(Color(255, 255, 255))
    
            TriangleCountLabel = vgui.Create("DLabel", ModelPanel)
            TriangleCountLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            TriangleCountLabel:SetPos(ModelnameLabel:GetX(), ModelPanel:GetTall() * 0.02)
            local MeshInfo = util.GetModelMeshes(ent:GetModel())
            local TriCount = 0
            for k, v in pairs(MeshInfo) do
                TriCount = TriCount + #v.triangles
            end
            TriangleCountLabel:SetText("Indexes Count: " .. TriCount)
            TriangleCountLabel:SetFont("DermaDefault")
            TriangleCountLabel:SetColor(Color(255, 255, 255))
    
            VertexCountLabel = vgui.Create("DLabel", ModelPanel)
            VertexCountLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            local LabelOffsetModelPanel = TriangleCountLabel:GetY() - ModelnameLabel:GetY()
            VertexCountLabel:SetPos(TriangleCountLabel:GetX(), TriangleCountLabel:GetY() + LabelOffsetModelPanel)
            local Vertices = 0
            for k, v in pairs(MeshInfo) do
                Vertices = Vertices + #v.verticies
            end
            VertexCountLabel:SetText("Vertices Count: " .. Vertices)
            VertexCountLabel:SetFont("DermaDefault")
            VertexCountLabel:SetColor(Color(255, 255, 255))
    
            BonesLabel = vgui.Create("DLabel", ModelPanel)
            BonesLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            BonesLabel:SetPos(VertexCountLabel:GetX(), VertexCountLabel:GetY() + LabelOffsetModelPanel)
            BonesLabel:SetText("Bones: " .. ent:GetBoneCount())
            BonesLabel:SetFont("DermaDefault")
            BonesLabel:SetColor(Color(255, 255, 255))
    
            HitboxesLabel = vgui.Create("DLabel", ModelPanel)
            HitboxesLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            HitboxesLabel:SetPos(BonesLabel:GetX(), BonesLabel:GetY() + LabelOffsetModelPanel)
            local Hitboxes = 0
            for i = 0, ent:GetHitboxSetCount() - 1 do
                Hitboxes = Hitboxes + ent:GetHitBoxCount(i)
            end
            HitboxesLabel:SetText("Hitboxes: " .. Hitboxes)
            HitboxesLabel:SetFont("DermaDefault")
            HitboxesLabel:SetColor(Color(255, 255, 255))
    
            BodygroupsLabel = vgui.Create("DLabel", ModelPanel)
            BodygroupsLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            BodygroupsLabel:SetPos(HitboxesLabel:GetX(), HitboxesLabel:GetY() + LabelOffsetModelPanel)
            BodygroupsLabel:SetText("Bodygroups: " .. Groups)
            BodygroupsLabel:SetFont("DermaDefault")
            BodygroupsLabel:SetColor(Color(255, 255, 255))

            FlexbonesCountLabel = vgui.Create("DLabel", ModelPanel)
            FlexbonesCountLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            FlexbonesCountLabel:SetPos(BodygroupsLabel:GetX(), BodygroupsLabel:GetY() + LabelOffsetModelPanel)
            FlexbonesCountLabel:SetText("Flexbones: " .. ent:GetFlexNum())
            FlexbonesCountLabel:SetFont("DermaDefault")
            FlexbonesCountLabel:SetColor(Color(255, 255, 255))
    
            EmptySpaceLabel = vgui.Create("DLabel", ModelPanel)
            EmptySpaceLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            EmptySpaceLabel:SetPos(BonesLabel:GetX(), FlexbonesCountLabel:GetY() + LabelOffsetModelPanel)
            EmptySpaceLabel:SetText("")
            EmptySpaceLabel:SetFont("DermaDefault")
            EmptySpaceLabel:SetColor(Color(255, 255, 255))
    
            FloorSizeLabel = vgui.Create("DLabel", ModelPanel)
            FloorSizeLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            FloorSizeLabel:SetPos(VertexCountLabel:GetX(), EmptySpaceLabel:GetY() + LabelOffsetModelPanel)
            FloorSizeLabel:SetText("Floor Size: 50x50 HU")
            FloorSizeLabel:SetFont("DermaDefault")
            FloorSizeLabel:SetColor(Color(255, 255, 255))
    
            ModelScaleLabel = vgui.Create("DLabel", ModelPanel)
            ModelScaleLabel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall() * 0.03)
            ModelScaleLabel:SetPos(FloorSizeLabel:GetX(), FloorSizeLabel:GetY() + LabelOffsetModelPanel)
            ModelScaleLabel:SetText("Model Scale: 1")
            ModelScaleLabel:SetFont("DermaDefault")
            ModelScaleLabel:SetColor(Color(255, 255, 255))
    
            -- //////////////////////////////////////// FUNCTIONALITY ////////////////////////////////////////
    
            function ModelPanel:OnMousePressed(code)
                if code == MOUSE_LEFT then
                    MVInfo.IsLeftDragging = true
                elseif code == MOUSE_RIGHT then
                    MVInfo.IsRightDragging = true
                elseif code == MOUSE_MIDDLE then
                    MVInfo.IsMiddleDragging = true
                end
                MVInfo.PreviousX, MVInfo.PreviousY = input.GetCursorPos()
            end
    
            function ModelPanel:OnMouseReleased(code)
                if code == MOUSE_LEFT then
                    MVInfo.IsLeftDragging = false
                elseif code == MOUSE_RIGHT then
                    MVInfo.IsRightDragging = false
                elseif code == MOUSE_MIDDLE then
                    MVInfo.IsMiddleDragging = false
                end
            end
    
            function ModelPanel:LayoutEntity(Entity)
                if MVInfo.IsLeftDragging then
                    -- Rotate the model according to the mouse movement
                    local x, y = input.GetCursorPos()
                    local XDelta = x - MVInfo.PreviousX
                    local YDelta = y - MVInfo.PreviousY
    
                    MVInfo.TotalXDelta = MVInfo.TotalXDelta + XDelta
                    MVInfo.TotalYDelta = MVInfo.TotalYDelta + YDelta
    
                    MVInfo.ModelAngle:RotateAroundAxis(Vector(0, 0, 1), MVInfo.TotalXDelta)
                    MVInfo.ModelAngle:RotateAroundAxis(Vector(0, 1, 0), -MVInfo.TotalYDelta)
                    self.Entity:SetAngles(MVInfo.ModelAngle)
                    MVInfo.ModelAngle = Angle(0, 0, 0)
    
                    MVInfo.PreviousX = x
                    MVInfo.PreviousY = y
    
                elseif MVInfo.IsRightDragging then
                    -- Scale the model according to the mouse movement
                    local x, y = input.GetCursorPos()
                    local delta = x - MVInfo.PreviousX
    
                    if self.Entity:GetModelScale() < 0.1 then
                        self.Entity:SetModelScale(0.1)
                    else
                        self.Entity:SetModelScale(self.Entity:GetModelScale() + delta * 0.01) 
                    end
    
                    MVInfo.PreviousX = x
                    FloorSizeLabel:SetText("Floor Size: " .. math.floor(self.Entity:GetModelScale() * 50) .. "x" .. math.floor(self.Entity:GetModelScale() * 50) .. " HU")
                    ModelScaleLabel:SetText("Model Scale: " .. string.format("%G", self.Entity:GetModelScale()))
    
                elseif MVInfo.IsMiddleDragging then
                    local x, y = input.GetCursorPos()
                    local XDelta = x - MVInfo.PreviousX
                    local YDelta = y - MVInfo.PreviousY
    
                    self:SetCamPos(self:GetCamPos() + Vector(0, XDelta, YDelta) * 0.2)
    
                    MVInfo.PreviousX = x
                    MVInfo.PreviousY = y
                end
    
                ModelPanel:RunAnimation()
                if (ModelPanel.Entity:IsSequenceFinished()) then
                    ModelPanel.Entity:SetCycle(0)
                    ModelPanel.Entity:ResetSequence(ModelPanel.Entity:GetSequence())
                    ModelPanel.Entity:SetPlaybackRate(PlaybackSlider:GetValue())
                end
    
                if (BonesCheckBox:GetChecked()) then
                    UpdateBones()
                end
    
                if (AttachmentsCheckBox:GetChecked()) then
                    UpdateAttachments()
                end

                function self:PreDrawModel() 
                    if (BackgroundCheckBox:GetChecked()) then
                        render.SetMaterial(Material("hlmv/background"))
                        render.DrawQuadEasy(ModelPanel:GetCamPos() + Vector(300, 0, 0), Vector(-1, 0, 0), 600, 600, Color(255, 255, 255), 180)
                    end
                end
            end
    
            function SequenceList:OnSelect(index, value, data)
                ModelPanel.Entity:SetCycle(0)
                ModelPanel.Entity:SetSequence(value)
                ModelPanel.Entity:ResetSequence(value)
            end
    
            -- another funny lua quirk I guess.
            PlaybackSlider.OnValueChanged = function( self, value )
                ModelPanel.Entity:SetPlaybackRate(value)
            end
    
            function SkinList:OnSelect(index, value, data)
                ModelPanel.Entity:SetSkin(index - 1)
            end
    
            function BonesCheckBox:OnChange(checked)
                if checked then
                    if not WireframeCheckBox:GetChecked() then
                        ModelPanel:SetColor(Color(255, 255, 255, 100))
                    end
                    for i = 1, ModelPanel.Entity:GetBoneCount() do
                        MVInfo.Bones[i] = vgui.Create("DModelPanel", ModelPanel)
                        MVInfo.Bones[i]:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall())
                        MVInfo.Bones[i]:SetPos(0, 0)
                        MVInfo.Bones[i]:SetModel("models/editor/axis_helper.mdl")
                        local BonePos, BoneAng = ModelPanel.Entity:GetBonePosition(i - 1)
                        MVInfo.Bones[i].Entity:SetPos(BonePos)
                        MVInfo.Bones[i].Entity:SetAngles(BoneAng)
                        MVInfo.Bones[i]:SetMouseInputEnabled(false)
                        MVInfo.Bones[i]:SetLookAng(Angle(0, 0, 0))
                    end
                else
                    if not AttachmentsCheckBox:GetChecked() and not DrawCollisionModelCheckBox:GetChecked() then
                        ModelPanel:SetColor(Color(255, 255, 255, 255)) 
                    end
                    for k, v in pairs(MVInfo.Bones) do
                        v:Remove()
                    end
                end
            end
    
            function UpdateBones()
                if #MVInfo.Bones > 0 and ModelPanel:IsValid() then
                    for k, v in pairs(MVInfo.Bones) do
                        if (v:IsValid()) then
                            function v:LayoutEntity(Entity)
                                local BonePos, BoneAngle = ModelPanel.Entity:GetBonePosition(k - 1)
                                v.Entity:SetPos(BonePos)
                                v.Entity:SetAngles(BoneAngle)
                                v:SetCamPos(ModelPanel:GetCamPos())
                                v.Entity:SetModelScale(ModelPanel.Entity:GetModelScale())
                            end
                        end
                    end
                end
            end 
    
            function AttachmentsCheckBox:OnChange(checked)
                if checked then
                    if not WireframeCheckBox:GetChecked() then
                        ModelPanel:SetColor(Color(255, 255, 255, 100)) 
                    end
                    for k, v in pairs(ModelPanel.Entity:GetAttachments()) do
                        MVInfo.Attachments[k] = vgui.Create("DModelPanel", ModelPanel)
                        MVInfo.Attachments[k]:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall())
                        MVInfo.Attachments[k]:SetPos(0, 0)
                        MVInfo.Attachments[k]:SetModel("models/editor/axis_helper.mdl")
                        MVInfo.Attachments[k].Entity:SetPos(ModelPanel.Entity:GetAttachment(k).Pos)
                        MVInfo.Attachments[k].Entity:SetAngles(ModelPanel.Entity:GetAttachment(k).Ang)
                        MVInfo.Attachments[k]:SetMouseInputEnabled(false)
                        MVInfo.Attachments[k]:SetLookAng(Angle(0, 0, 0))
                    end
                else
                    if not BonesCheckBox:GetChecked() and not DrawCollisionModelCheckBox:GetChecked() then
                        ModelPanel:SetColor(Color(255, 255, 255, 255)) 
                    end
                    for k, v in pairs(MVInfo.Attachments) do
                        v:Remove()
                    end
                end
            end
    
            function UpdateAttachments()
                if #MVInfo.Attachments > 0 and ModelPanel:IsValid() then
                    for k, v in pairs(MVInfo.Attachments) do
                        if (v:IsValid()) then
                            function v:LayoutEntity(Entity)
                                v.Entity:SetPos(ModelPanel.Entity:GetAttachment(k).Pos)
                                v.Entity:SetAngles(ModelPanel.Entity:GetAttachment(k).Ang)
                                v:SetCamPos(ModelPanel:GetCamPos())
                                v.Entity:SetModelScale(ModelPanel.Entity:GetModelScale())
                            end
                        end
                    end
                end
            end
    
            function DrawCollisionModelCheckBox:OnChange(checked)
                if checked then
                    if not WireframeCheckBox:GetChecked() then
                        ModelPanel:SetColor(Color(255, 255, 255, 100)) 
                    end
                    local ENT = scripted_ents.Get("PhysMDL")
                    ENT:SetEnt(ModelPanel.Entity)
                    scripted_ents.Register(ENT, "PhysMDL")
                    mdl = ents.CreateClientside("PhysMDL")
                    mdl:Spawn()
                    mdl:AddEffects(EF_NODRAW)
    
                    CollisionModelPanel = vgui.Create("DModelPanel", ModelPanel)
                    CollisionModelPanel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall())
                    CollisionModelPanel:SetPos(0, 0)
                    CollisionModelPanel:SetEntity(mdl)
                    CollisionModelPanel:SetMouseInputEnabled(false)
                    CollisionModelPanel:SetCamPos(ModelPanel:GetCamPos())
                    CollisionModelPanel:SetLookAng(Angle(0, 0, 0))
        
                    function CollisionModelPanel:LayoutEntity()
                        local ENT = scripted_ents.Get("PhysMDL")
                        ENT:UpdateAngles(ModelPanel.Entity:GetAngles())
                        ENT:UpdateScale(ModelPanel.Entity:GetModelScale())
                        self:SetCamPos(ModelPanel:GetCamPos())
                        scripted_ents.Register(ENT, "PhysMDL")
                    end
                else
                    if not AttachmentsCheckBox:GetChecked() and not BonesCheckBox:GetChecked() then
                        ModelPanel:SetColor(Color(255, 255, 255, 255))
                    end
                    mdl:Remove()
                    CollisionModelPanel:Remove()
                end
            end
    
            function WireframeCheckBox:OnChange(checked)
                if checked then
                    local ModelMaterial = ModelPanel.Entity:GetMaterial()
                    ModelPanel.Entity:SetMaterial("models/wireframe")
                else
                    ModelPanel.Entity:SetMaterial(ModelMaterial)
                end
            end
    
            function FloorCheckBox:OnChange(checked)
                if checked then
                    Floor = ents.CreateClientside("mv_floor")
                    Floor:Spawn()
                    Floor:AddEffects(EF_NODRAW)
                    FloorModelPanel = vgui.Create("DModelPanel", ModelPanel)
                    FloorModelPanel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall())
                    FloorModelPanel:SetPos(0, 0)
                    FloorModelPanel:SetEntity(Floor)
                    FloorModelPanel:SetMouseInputEnabled(false)
                    FloorModelPanel:SetCamPos(ModelPanel:GetCamPos())
                    FloorModelPanel:SetLookAng(Angle(0, 0, 0))
                    FloorModelPanel:MoveToBack()
    
                    function FloorModelPanel:LayoutEntity()
                        local ENT = scripted_ents.Get("mv_floor")
                        ENT:UpdateAngles(ModelPanel.Entity:GetAngles())
                        ENT:UpdateScale(ModelPanel.Entity:GetModelScale())
                        self:SetCamPos(ModelPanel:GetCamPos())
                        scripted_ents.Register(ENT, "mv_floor")
                    end
                else
                    Floor:Remove()
                    FloorModelPanel:Remove()
                end
            end

            function HitboxCheckBox:OnChange(checked)
                if checked then
                    HitboxesPanel = vgui.Create("DModelPanel", ModelPanel)
                    HitboxesPanel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall())
                    HitboxesPanel:SetPos(0, 0)
                    HitboxesPanel:SetModel("models/editor/axis_helper.mdl")
                    HitboxesPanel:SetColor(Color(0, 0, 0, 0))
                    HitboxesPanel:SetMouseInputEnabled(false)
                    HitboxesPanel:SetCamPos(ModelPanel:GetCamPos())
                    HitboxesPanel:SetLookAng(Angle(0, 0, 0))
                    local OrgZ, OrgY = ModelPanel:GetCamPos().z, ModelPanel:GetCamPos().y
                    function HitboxesPanel:PostDrawModel()
                        render.SetColorMaterial()
                        for s = 0, ModelPanel.Entity:GetHitboxSetCount() - 1 do
                            for h = 0, ModelPanel.Entity:GetHitBoxCount(s) - 1 do
                                BoxMin, BoxMax = ModelPanel.Entity:GetHitBoxBounds(h, s)
                                BoneMatrix = ModelPanel.Entity:GetBoneMatrix(ModelPanel.Entity:GetHitBoxBone(h, s))
                                render.DrawWireframeBox(BoneMatrix:GetTranslation() + Vector(0, -ModelPanel:GetCamPos().y + OrgY, -ModelPanel:GetCamPos().z + OrgZ), BoneMatrix:GetAngles(), BoxMin * ModelPanel.Entity:GetModelScale(), BoxMax * ModelPanel.Entity:GetModelScale(), Color(255, 255, 255, 150))
                            end
                        end
                    end
                else
                    HitboxesPanel:Remove()
                end
            end

            function BBoxCheckbox:OnChange(checked)
                if checked then
                    BboxPanel = vgui.Create("DModelPanel", ModelPanel)
                    BboxPanel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall())
                    BboxPanel:SetPos(0, 0)
                    BboxPanel:SetModel("models/editor/axis_helper.mdl")
                    BboxPanel:SetColor(Color(0, 0, 0, 0))
                    BboxPanel:SetMouseInputEnabled(false)
                    BboxPanel:SetCamPos(ModelPanel:GetCamPos())
                    BboxPanel:SetLookAng(Angle(0, 0, 0))
                    local OrgZ, OrgY = ModelPanel:GetCamPos().z, ModelPanel:GetCamPos().y
                    local BboxMin, BboxMax = ModelPanel.Entity:GetModelBounds()
                    function BboxPanel:PostDrawModel()
                        render.SetColorMaterial()
                        render.DrawWireframeBox(Vector(0, 0, 0) + Vector(0, -ModelPanel:GetCamPos().y + OrgY, -ModelPanel:GetCamPos().z + OrgZ), ModelPanel.Entity:GetAngles(), BboxMin * ModelPanel.Entity:GetModelScale(), BboxMax * ModelPanel.Entity:GetModelScale(), Color(255, 255, 255, 150))
                    end
                else
                    BboxPanel:Remove()
                end
            end
    
            function AmbientColorMixer:ValueChanged()
                ModelPanel:SetAmbientLight(AmbientColorMixer:GetColor())
            end
        end
    end

    -- //////////////////////////////////////// END MAIN ////////////////////////////////////////

    hook.Add("OnScreenSizeChanged", "PrintOld", function()
        MVInfo.SizeX = ScrW() * 1000 / 1280
        MVInfo.SizeY = ScrH() * 700 / 720
        MVInfo.X = ScrW() / 2 - MVInfo.SizeX / 2
        MVInfo.Y = ScrH() / 2 - MVInfo.SizeY / 2
        if IsValid(Window) then
            Window:SetPos(MVInfo.X, MVInfo.Y) 
            Window:SetSize(MVInfo.SizeX, MVInfo.SizeY)
            Window:Remove()
        end
    end)

    net.Receive( "CreateWindow", function( len, ply )
        local Ent = net.ReadEntity()
        CreateWindow(Ent)
    end)
end
