package ru.bmstu.rk9.rao.ui.process.release;

import org.eclipse.draw2d.IFigure;

import ru.bmstu.rk9.rao.ui.process.node.BlockEditPart;

public class ReleaseEditPart extends BlockEditPart {

	@Override
	protected IFigure createFigure() {
		IFigure figure = new ReleaseFigure();
		return figure;
	}
}