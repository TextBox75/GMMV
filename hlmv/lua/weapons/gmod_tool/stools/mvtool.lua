if CLIENT then
    TOOL.Category = "Model Viewer"
    TOOL.Name = "Model Viewer Tool"

    language.Add("Tool.mvtool.name", "Model Viewer Tool")
	language.Add("Tool.mvtool.desc", "Display the model of entity shot in model viewer")
	TOOL.Information = {{name = "left"}}
    language.Add("tool.mvtool.left", "Fire at will!")

    function TOOL.BuildCPanel(panel)
		panel:AddControl("label", {
			text = "Shows the model of the entity shot in the model viewer!",
		})
	end
end

function TOOL:LeftClick(tr)
    if IsValid(tr.Entity) then
        util.AddNetworkString("CreateWindow")
        net.Start("CreateWindow")
        net.WriteEntity(tr.Entity)
        net.Send(self:GetOwner())
        return true
    end
end