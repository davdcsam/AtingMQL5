

# Automated Trading for MQL5

The AutomatedTrading library is designed to simplify everyday tasks in the development of bots in MQL5. Below is a detailed explanation of each module included in it:

# Demo Visualization

<p align="center"><img src="res/testAutomatedTradingMQL5.gif"></p>

This demo mainly uses the modules transaction, single lapse time, profit protection and trailing stop.


### Transaction (Enhanced CTrade Class)

- **Automatic Filling Mode Selection:** Automatically chooses the best filling method based on market conditions and symbol requirements.
- **Invalid Input Alerts:** Provides warnings for invalid inputs to ensure smooth order execution.
- **Pending Order Handling:** Automatically determines the type of pending order (limits or stops) based on market logic.
- **Stop Calculation & Volume Rounding:** Calculates stop levels and rounds order volumes to meet symbol requirements.

### Order and Position Detection

- **By Magic Number and Symbol:** Efficiently manage and identify orders and positions using magic numbers and symbols.

### Operational Day and Date Filtering

- **Day of the Week Filtering:** Operate only on specified days of the week.
- **CSV-based Date Filtering:** For backtesting, filter operational dates based on a CSV file for precise historical testing.

### Institutional Arithmetic Price Generation

- **Price Calculation:** Generate institutional arithmetic prices to aid in decision-making based on key market levels.

### Signal Generation

- **Time Range Limits:** Create trading signals based on price limits within specific time ranges.
- **Index-Based Limits:** Generate signals based on predefined market indices.

### Profit Protection

- **Breakeven:** Automatically adjust stop loss to breakeven once a certain profit level is reached.
- **Trailing Stop:** Dynamically move the stop loss to protect profits as the price moves favorably.

### Order Removal

- **By Magic Number and Symbol:** Easily cancel specific orders using magic numbers and symbols for streamlined order management.

### Time Range Definition

- **TimeLapseTree Class:** Store and manage multiple time ranges, facilitating complex trading strategies.

- **SectionTime Class:** For handling a single time section, used by the Multi Lapse class for more detailed time management.

### Experimental Task Manager

- **OnTimer Event Implementation:** Execute all library modules periodically using the OnTimer event for organized and scheduled task execution.

# Documentation

So sorry, docs in dev.

# Test

So sorry, test in dev.

# Tech Stack

**Client:** MetaTrader 5 Terminal

# Installation

## Repository

1. Clone the repository to your local machine.

2. Navigate to the MQL5 folder in the MetaTrader 5 directory.

3. Copy the cloned repository into the MQL5 folder.

## Quick Usage

1. Open MetaTrader 5.

2. Navigate to the Navigator window and expand the Expert Advisors tree.

3. Find your project and drag it onto any chart window.

## Creating an Executable File

1. Open MetaEditor from MetaTrader 5 (press F4).

2. Open your project.

3. Open the file `.mq5`.

4. Press F7 to compile. The `.ex5` file will be created in the same directory and verify the code hasn't syntax errors.

# Authors

- [@davdcsam](https://www.github.com/davdcsam)

## Support

For support, email <edavidcamposl@gmail.com>, <00514724@uca.edu.sv>, [X](https://x.com/davdcsam) & [Instagram](https://www.instagram.com/davdcsam/)

## License

[MIT](https://choosealicense.com/licenses/mit/)

![Logo](res/automatedtrading.png)
