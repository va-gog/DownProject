# DOWN APP PROJECT

## Introduction
This project demonstrates the process of downloading and displaying user profiles from a JSON URL. The application uses lazy loading for images, caching mechanisms, and animated transitions to enhance the user experience.

## Table of Contents
- [Project Overview](#project-overview)
- [Technologies Used](#technologies-used)
- [Completion Date](#completion-date)
- [Key Features and Implementations](#key-features-and-implementations)
- [Challenges and Solutions](#challenges-and-solutions)
- [Testing](#testing)
- [Future Improvements](#future-improvements)

## Project Overview
The project involves downloading a JSON file from a URL, decoding it into profiles, and displaying these profiles on the screen. During the download process, a loading indicator is shown. Lazy loading is employed for profile images, and images are fetched before the cells appear in the collection view. An NSCache is used with specific settings to optimize performance and avoid reloading images every time a cell appears.

A filter collection view, inspired by the Down app, is implemented using a local JSON file. When profiles in the filter are empty, an empty view is shown, and an error view with a reload button is displayed if an error occurs. Profile swiping triggers animations, including the "DOWN? DATE" label appearance and transitions to the next or previous profile.

## Technologies Used
- UIKIT
- Combine
- MVVM
- Strategy Pattern
- Bridge Pattern 

## Completion Date
The project was completed on 01.07.2024

## Key Features and Implementations
- **Lazy Loading of Images**: Optimizes image loading using fetch logic in the collection view.
- **Caching**: Utilizes NSCache with specific settings to prevent reloading images.
- **Loading Indicator**: Displays during the download process.
- **Filter Collection View**: Mimics the Down app filters using a local JSON file.
- **Empty and Error Views**: Displays appropriate views when profiles are empty or an error occurs.
- **Animated Transitions**: Includes animations for swiping profiles and scrolling vertically.
- **UI Design**: Inspired by the Down app but not identical.

## Challenges and Solutions
- **Lazy Loading and Caching**: Implemented lazy loading and caching to optimize performance and user experience.
- **Animations**: Developed smooth and responsive animations for profile transitions and scrolling.

## Testing
- **Unit Tests**: Unit tests are implemented for view models and services.

## Future Improvements
- **Pagination**: Implement pagination for profile loading to handle large profile counts.
- **Localization and Text Size Logic**: Add localization and text size handling for a more comprehensive solution.

