package ru.bmstu.rk9.rao.ui.process.node;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;

public abstract class BlockNodeWithProbability extends BlockNode {

	private static final long serialVersionUID = 1;

	public static final String PROPERTY_PROBABILITY = "NodeProbability";

	protected String probability = "0.5";

	public String getProbability() {
		return probability;
	}

	public void setProbability(String probability) {
		String oldProbability = this.probability;
		this.probability = probability;
		getListeners().firePropertyChange(PROPERTY_PROBABILITY, oldProbability, probability);
	}

	public void validateProbability(IResource file) throws CoreException {
		boolean valid = true;
		try {
			double probability = Double.valueOf(this.probability);
			if (probability < 0 || probability > 1)
				valid = false;
		} catch (NumberFormatException e) {
			valid = false;
		}
		if (!valid) {
			IMarker marker = file.createMarker(BlockNode.PROCESS_MARKER);
			marker.setAttribute(IMarker.MESSAGE, "Wrong probability");
			marker.setAttribute(IMarker.LOCATION, getName());
			marker.setAttribute(IMarker.SEVERITY, IMarker.SEVERITY_ERROR);
		}
	}
}