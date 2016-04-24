package ru.bmstu.rk9.rao.ui.gef;

import java.util.function.Supplier;

import org.eclipse.gef.editparts.AbstractEditPart;

public class NodeInfo {

	public NodeInfo(String name, Supplier<Node> nodeFactory, Supplier<AbstractEditPart> partFactory) {
		this.name = name;
		this.nodeFactory = nodeFactory;
		this.partFactory = partFactory;
	}

	private final String name;
	private final Supplier<Node> nodeFactory;
	private final Supplier<AbstractEditPart> partFactory;

	public String getName() {
		return name;
	}

	public Supplier<Node> getNodeFactory() {
		return nodeFactory;
	}

	public Supplier<AbstractEditPart> getPartFactory() {
		return partFactory;
	}
}