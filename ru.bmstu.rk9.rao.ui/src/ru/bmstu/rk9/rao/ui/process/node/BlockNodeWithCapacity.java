package ru.bmstu.rk9.rao.ui.process.node;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;

import ru.bmstu.rk9.rao.lib.process.Queue.Queueing;

public abstract class BlockNodeWithCapacity extends BlockNode {

	private static final long serialVersionUID = 1;

	public static final String PROPERTY_CAPACITY = "NodeCapacity";
	public static final String PROPERTY_QUEUEING = "NodeQueueing";

	protected String capacity = "";
	protected Queueing queueing = Queueing.FIFO;

	public String getCapacity() {
		return capacity;
	}

	public void setCapacity(String capacity) {
		String oldCapacity = this.capacity;
		this.capacity = capacity;
		getListeners().firePropertyChange(PROPERTY_CAPACITY, oldCapacity, capacity);
	}

	public Integer getQueueingIndex() {
		return queueing.ordinal();
	}

	public void setQueueing(int index) {
		Queueing oldQueueig = this.queueing;
		this.queueing = Queueing.values()[index];
		getListeners().firePropertyChange(PROPERTY_QUEUEING, oldQueueig, queueing);
	}

	protected final void validateCapacity(IResource file) throws CoreException {
		if (capacity.isEmpty())
			return;
		try {
			Double.valueOf(capacity);
		} catch (NumberFormatException e) {
			IMarker marker = file.createMarker(BlockNode.PROCESS_MARKER);
			marker.setAttribute(IMarker.MESSAGE, "Wrong capacity");
			marker.setAttribute(IMarker.LOCATION, this.getName());
			marker.setAttribute(IMarker.SEVERITY, IMarker.SEVERITY_ERROR);
		}
	}
}