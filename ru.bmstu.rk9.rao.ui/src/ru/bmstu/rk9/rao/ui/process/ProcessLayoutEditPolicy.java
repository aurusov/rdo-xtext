package ru.bmstu.rk9.rao.ui.process;

import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editpolicies.XYLayoutEditPolicy;
import org.eclipse.gef.requests.CreateRequest;

import ru.bmstu.rk9.rao.ui.process.command.ChangeLayoutCommand;
import ru.bmstu.rk9.rao.ui.process.command.CreateCommand;
import ru.bmstu.rk9.rao.ui.process.command.LayoutCommand;
import ru.bmstu.rk9.rao.ui.process.model.ModelPart;

public class ProcessLayoutEditPolicy extends XYLayoutEditPolicy {

	public static final int FIGURE_WIDTH = 50;
	public static final int FIGURE_HEIGHT = 60;

	@Override
	protected Command createChangeConstraintCommand(EditPart child, Object constraint) {
		LayoutCommand command = null;

		if (!ProcessEditor.processNodesInfo.containsKey(child.getModel().getClass()))
			return null;

		command = new ChangeLayoutCommand();
		command.setModel(child.getModel());
		command.setConstraint((Rectangle) constraint);
		return command;
	}

	@Override
	protected Command getCreateCommand(CreateRequest request) {
		if (request.getType() == REQ_CREATE && getHost() instanceof ModelPart) {
			CreateCommand command = new CreateCommand();
			command.setModel(getHost().getModel());
			command.setNode(request.getNewObject());

			Rectangle constraint = (Rectangle) getConstraintFor(request);
			constraint.x = (constraint.x < 0) ? 0 : constraint.x;
			constraint.y = (constraint.y < 0) ? 0 : constraint.y;
			constraint.width = FIGURE_WIDTH;
			constraint.height = FIGURE_HEIGHT;
			command.setLayout(constraint);
			return command;
		}
		return null;
	}

}