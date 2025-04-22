Predictive Maintenance App for NEMO® Progressive Cavity Pumps

This repository contains the source code and documentation for a mobile application designed to support predictive maintenance of NETZSCH NEMO® progressive cavity pumps. The app helps users anticipate optimal adjustment or replacement intervals for the xLC® component, enhancing pump lifespan and minimizing unplanned downtimes.

🚀 Purpose

NETZSCH pumps, particularly those with the patented xLC® stator adjustment system, allow for increased service life by compensating wear through axial adjustment. However, deciding when to perform these adjustments remains a challenge in practice. This app leverages operating data and wear models to provide accurate, real-time insights for:

- Predicting stator wear
- Recommending adjustment intervals
- Visualizing remaining life and efficiency loss
- Enabling timely procurement of spare parts

🧠 Technology Stack

- Frontend: Flutter + Riverpod architecture
- Backend/Logic: Dart-based regression models
- Data Handling: Persisted user inputs for tracking operational history
- Architecture: Inspired by Clean Architecture — domain, data, application, and presentation layers

📚 Background

This app is part of a Bachelor's thesis project in collaboration with NETZSCH Pumps & Systems GmbH, and builds upon prior research including:

- Tribological wear analysis using Miller and ROG tribometers
- Laboratory data from NETZSCH’s Technikum
- The xLC® stator adjustment system and its influence on pump performance and wear

🧪 Evaluation

The app's prediction models are based on empirical data from NETZSCH and ongoing analysis. Future improvements include integrating live sensor data and supporting additional pump configurations.