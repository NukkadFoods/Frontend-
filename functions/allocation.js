const functions = require("firebase-functions");
const admin = require("firebase-admin");
const math = require("mathjs");
const { FieldValue } = require("firebase-admin/firestore");

async function allocateOrder(order, restaurant, hubId, user) {
    order.accepted = null;
    var db = admin.firestore();
    const queue = (await db.collection('hubs').doc(hubId).get()).get('queue');
    let dboysWithPriority = [];
    if (Array.isArray(queue)) {
        queue.forEach((driver) => {
            let distanceInKm = calcCrow(driver.lat, driver.lng, restaurant.lat, restaurant.lng);
            let waitingTime = getWaitingTime(driver.waitingFrom);
            let hubPoints = driver.hubId === hubId ? .2 : .6;
            if (distanceInKm < .1) {
                distanceInKm = .1;
            }
            const priority = 0.2 / distanceInKm + .5 * waitingTime + .3 * hubPoints;
            driver.priority = priority;
            dboysWithPriority.push(driver);
        });
    }
    dboysWithPriority = dboysWithPriority.sort((b, a) => a.priority - b.priority);
    let orderAssigned = false;
    for (let i = 0; i < dboysWithPriority.length; i++) {
        if (dboysWithPriority[i].hubId !== hubId && dboysWithPriority[i].takeHome) {
            let hubDetails = await db.collection('hubs').doc(dboysWithPriority[i].hubId).get();
            let newDistance = calcCrow(hubDetails.data.lat, hubDetails.data.lng, user.lat, user.lng);
            let homeDistance = calcCrow(dboysWithPriority[i].lat, dboysWithPriority[i].lng, hubDetails.data.lat, hubDetails.data.lng);
            if (homeDistance < newDistance) {
                continue;
            }
        }
        await db.collection('dboys').doc(dboysWithPriority[i].id).update(
            {
                "orders": FieldValue.arrayUnion(order)
            }
        );
        let accepted = await waitforResult(dboysWithPriority[i].id, order);
        if (accepted === true) {
            let dboy = dboysWithPriority[i];
            delete dboy.priority;
            await db.collection('hubs').doc(hubId).update({
                "queue": FieldValue.arrayRemove(dboy)
            });
            orderAssigned = true;
            break;
        } else {
            await db.collection('dboys').doc(dboysWithPriority[i].id).update(
                {
                    "orders": FieldValue.arrayRemove(order)
                }
            );
        }
    }
    if (orderAssigned === false) {
        let data = (await db.collection('hubs').doc(hubId).get()).data();

        if (data.unassigned === undefined) {
            db.collection('hubs').doc(hubId).update({
                'unassigned': FieldValue.arrayUnion(order)
            });
        } else if (Array.isArray(data.unassigned) && data.unassigned.filter((value) => value['orderId'] === order['orderId']).length === 0) {
            db.collection('hubs').doc(hubId).update({
                'unassigned': FieldValue.arrayUnion(order)
            });
        }


    }
}


function calcCrow(lat1, lon1, lat2, lon2) {
    var R = 6371; // km
    var dLat = toRad(lat2 - lat1);
    var dLon = toRad(lon2 - lon1);
    var lat1 = toRad(lat1);
    var lat2 = toRad(lat2);

    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c;
    return d;
}

// Converts numeric degrees to radians
function toRad(Value) {
    return Value * Math.PI / 180;
}

function getWaitingTime(dateTime) {
    const now = new Date();
    const givenDate = new Date(dateTime);
    const diffInMilliSecs = now - givenDate;
    return Math.floor(diffInMilliSecs / 60000);
}

function waitforResult(dboyId, order) {
    return new Promise((resolve, reject) => {
        const timeoutId = setTimeout(() => {
            resolve(false);
        }, 60000); // Timeout after 1 minutes (60000ms)
        let ref = admin.firestore().collection('dboys').doc(dboyId);
        try {
            const unsubscribe = ref.onSnapshot((docSnapshot) => {
                const data = docSnapshot.data();
                if (Array.isArray(data.orders)) {
                    for (const item of data.orders) {
                        if (item.orderId === order.orderId) {
                            clearTimeout(timeoutId);
                            if (item.accepted !== null) {
                                resolve(item.accepted);
                                unsubscribe();
                                return;
                            }
                        }
                    }
                }
            });
        } catch (error) {
            clearTimeout(timeoutId);  // Clear timeout if there's an error
            reject(error);  // Reject the promise with the error
        }
    });
}

module.exports = { allocateOrder };