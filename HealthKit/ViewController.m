//
//  ViewController.m
//  Simple sample to show HealthKit features
//
//  Created by Alejandro Luengo on 30/09/14.
//  (c) 2014 Intelygenz

#import "ViewController.h"

@import HealthKit;

@implementation ViewController
{
    HKHealthStore *_store;
    dispatch_queue_t _syncQueue;
    dispatch_queue_t _asyncQueue;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    _asyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _syncQueue = dispatch_queue_create("sync", NULL);
    
    // Prepares HealthKit to get/put data
    [self setupHealth];
    
    // Add observer to automatically grab data when HealthKit updates
    [self addObserver];
    
    // Create and Save an object
    [self createAndSaveHealthObject];
    
    // Get data from HealthKit
    [self queryToStore];

}


#pragma mark - Setup Health Kit.

- (void)setupHealth
{
   
    if ([HKHealthStore isHealthDataAvailable])
    {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        _store = [[HKHealthStore alloc] init];
        [_store requestAuthorizationToShareTypes: writeDataTypes readTypes: readDataTypes completion:^(BOOL success, NSError *error) {
            NSLog(@"%i", success);
        }];
    }
    
}


// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite
{
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    return [NSSet setWithObjects: weightType, nil];
}


// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead
{
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    
    return [NSSet setWithObjects: weightType, birthdayType, nil];
}


#pragma mark - Adds observer for weight type.

// Adds observer for mass.
- (void) addObserver
{

    HKQuantityType *massType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierBodyMass];
    HKObserverQuery *query = [[HKObserverQuery alloc] initWithSampleType:massType predicate:nil
                                                           updateHandler:^(HKObserverQuery *query,
                                                                           HKObserverQueryCompletionHandler completionHandler, NSError *error)
                              {
                                  NSLog(@"Update!");
                              }];
    
    [_store executeQuery: query];

}


#pragma mark - Create and save health object.

// Saving objects.
- (void)createAndSaveHealthObject
{
 
    HKQuantitySample *sample = [self createQuantity];
    
    [_store saveObject: sample withCompletion:^(BOOL success, NSError *error) {
        if ( success ){
            NSLog(@"Saved!");
        } else if (error) {
            NSLog(@"%@", error);
        }
    }];

}

// Creating an HKObject
- (HKQuantitySample *)createQuantity
{

    HKQuantityType *tmpQuantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];

    HKQuantity *tmpQuantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:82 * 1000];
    
    HKQuantitySample *massSample = [HKQuantitySample quantitySampleWithType:tmpQuantityType
                                                                   quantity:tmpQuantity
                                                                  startDate:[NSDate date]
                                                                    endDate:[NSDate date]
                                                                   metadata:nil];
    return massSample;
    
}


#pragma mark - Query to the store.

// Query to get weight.
- (void)queryToStore
{
    
    HKQuantityType *massType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    NSString *endKey = HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDate = [NSSortDescriptor sortDescriptorWithKey:endKey ascending: NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: massType
                                                           predicate: nil
                                                               limit: 1
                                                     sortDescriptors:@[endDate]
                                                      resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error)
                            {
                                HKQuantitySample *resultSample = [results lastObject];
                                NSLog(@"Result of query: %@", resultSample);
                            }];
    
    [_store executeQuery: query];
    
}


#pragma mark - Fetching new objects.

// Fetching new objects.
- (void) getObjects
{
    
    HKQuantityType *mass = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierBodyMass];
    HKAnchoredObjectQuery *query = [[HKAnchoredObjectQuery alloc] initWithType: mass
                                                                     predicate: nil
                                                                        anchor: 0
                                                                         limit:HKObjectQueryNoLimit
                                                             completionHandler:^(HKAnchoredObjectQuery *query,
                                                                                 NSArray *results,
                                                                                 NSUInteger newAnchor,
                                                                                 NSError *error)
                                    {
                                        NSLog(@"Result: %@", results);
                                    }];
    [_store executeQuery: query];
    
}

@end
