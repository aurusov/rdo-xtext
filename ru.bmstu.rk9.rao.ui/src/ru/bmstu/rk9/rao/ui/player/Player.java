package ru.bmstu.rk9.rao.ui.player;

import java.util.ArrayList;
import java.util.List;

import ru.bmstu.rk9.rao.lib.database.Database;
import ru.bmstu.rk9.rao.lib.event.Event;
import ru.bmstu.rk9.rao.lib.modeldata.StaticModelData;
import ru.bmstu.rk9.rao.lib.notification.Notifier;
import ru.bmstu.rk9.rao.lib.simulator.CurrentSimulator;
import ru.bmstu.rk9.rao.lib.simulator.CurrentSimulator.ExecutionState;
import ru.bmstu.rk9.rao.lib.simulator.CurrentSimulator.SimulationStopCode;
import ru.bmstu.rk9.rao.lib.simulator.ISimulator;
import ru.bmstu.rk9.rao.lib.simulator.ModelState;
import ru.bmstu.rk9.rao.lib.simulator.SimulatorInitializationInfo;
import ru.bmstu.rk9.rao.lib.simulator.SimulatorPreinitializationInfo;

public class Player implements Runnable, ISimulator {

	private void delay(int time) {
		try {
			Thread.sleep(time);
		} catch (InterruptedException ex) {
			Thread.currentThread().interrupt();
		}
	}

	public enum PlayingDirection {
		FORWARD, BACKWARD;
	};

	private int PlaingSelector(int currentEventNumber, PlayingDirection playingDirection) {

		switch (playingDirection) {
		case FORWARD:
			currentEventNumber++;
			break;
		case BACKWARD:
			currentEventNumber--;
			break;

		default:
			System.out.println("Invalid grade");
		}

		return currentEventNumber;

	}

	public List<ModelState> getModelData() {

		return Reader.retrieveStateStorage();

	}

	public static void stop() {
		System.out.println("Stop");
		state = "Stop";
	}

	public static void pause() {
		System.out.println("Pause");
		state = "Pause";
	}

	public static void play() {
		Thread thread = new Thread(new Player());
		thread.start();
		System.out.println("Play");
		state = "Play";
	}

	private synchronized void runPlayer(int currentEventNumber, int time, PlayingDirection playingDirection) {

		modelStateStorage = getModelData();
		CurrentSimulator.set(new Player());
		while (state != "Stop" && state != "Pause" && currentEventNumber < (modelStateStorage.size() - 1)
				&& currentEventNumber > 0) {
			delay(time);

			System.out.println("Event: " + modelStateStorage.get(currentEventNumber));
			currentEventNumber = PlaingSelector(currentEventNumber, playingDirection);

		}
		System.out.println("Plaing done");
		currentEventNumber = 1;
		if (state == "Stop") {
			Player.currentEventNumber = 1;
		} else {
			Player.currentEventNumber = currentEventNumber;
		}

	}

	public void run() {
		// notifyChange(ExecutionState.EXECUTION_STARTED);
		// notifyChange(ExecutionState.TIME_CHANGED);
		// notifyChange(ExecutionState.STATE_CHANGED);
		runPlayer(currentEventNumber, 1000, PlayingDirection.FORWARD);

		return;
	}

	private static volatile String state = new String("");
	private volatile static Integer currentEventNumber = new Integer(1);
	private List<ModelState> modelStateStorage = new ArrayList<ModelState>();

	@Override
	public void preinitilize(SimulatorPreinitializationInfo info) {
		// TODO Auto-generated method stub

	}

	@Override
	public void initialize(SimulatorInitializationInfo initializationInfo) {
		// TODO Auto-generated method stub
		executionStateNotifier = new Notifier<ExecutionState>(ExecutionState.class);
	}

	@Override
	public Database getDatabase() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public StaticModelData getStaticModelData() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ModelState getModelState() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void setModelState(ModelState modelState) {
		// TODO Auto-generated method stub

	}

	@Override
	public double getTime() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void pushEvent(Event event) {
		// TODO Auto-generated method stub

	}

	private Notifier<ExecutionState> executionStateNotifier;

	@Override
	public Notifier<ExecutionState> getExecutionStateNotifier() {
		// TODO Auto-generated method stub
		return executionStateNotifier;
	}

	@Override
	public void notifyChange(ExecutionState category) {
		// TODO Auto-generated method stub
		executionStateNotifier.notifySubscribers(category);

	}

	@Override
	public void abortExecution() {
		// TODO Auto-generated method stub

	}

	@Override
	public SimulationStopCode runSimulator() {
		// TODO Auto-generated method stub
		return null;
	}

}
