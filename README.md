

# Automated Trading for MQL5

The AutomatedTrading library is designed to simplify everyday tasks in the development of bots in MQL5. Below is a detailed explanation of each module included in it:

# Demo Visualization

<p align="center"><img src="res/testAutomatedTradingMQL5.gif"></p>

This demo mainly uses the modules transaction, single lapse time, profit protection and trailing stop.


## Transaction (Improve of CTrade)

### Automatic Filling Mode Selection

Automates the choice of order filling method based on market conditions and symbol requirements.

### Invalid Input Warnings

Provides warning messages when the inputs provided for the transaction are invalid.

### Sending Custom Pending Orders

Allows sending pending orders without specifying whether they are limits or stops, determining it automatically based on market logic.
Stop Calculation and Volume Rounding: Automates the calculation of stop levels and adjusts the volume of orders according to the symbol requirements.

## Orders and Positions Detection by Magic Number and Symbol

Facilitates the identification and management of orders and positions using the magic number and the associated symbol, allowing a more efficient management of transactions.

## Operating Days and Dates Filter

### Weekday Filter

Allows trading only on specific days of the week.

### CSV-based Date Filter

For backtesting, allows filtering trading dates based on a CSV document, providing greater flexibility and accuracy in historical testing.

## Institutional Arithmetic Price Generation

Calculates institutional average prices to facilitate decision making based on key market price levels.

## Signal Generation by Time Limits and IndicesTime Range Limits

Generates trading signals based on price limits defined by a specific time range.
Limits by Indices: Generates signals based on predefined market indices.

## Percentage Profit ProtectionBreakeven

Automatically adjusts the stop loss to a break even level when the position has reached a certain profit level. Also include a trailing stop: Moves the stop loss following the price to protect profits as the price moves in the favorable direction.

## Order Deletion by Magic Number and Symbol

Facilitates the cancellation of specific orders using the magic number and symbol, optimizing the management of pending orders.

## Time Range Definition

### Multi Lapse

Class that allows storing multiple time ranges, facilitating the management of operations in different time periods and improving the bot's efficiency.

### Single Lapse

Class to allow a single section time. This class is used by Multi Lapse.

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
