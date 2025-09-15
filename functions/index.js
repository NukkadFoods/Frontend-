/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");


const functions = require("firebase-functions");
const admin = require("firebase-admin");
const math = require("mathjs");

admin.initializeApp();
const { allocateOrder, notify } = require("./allocation");

function nukkad(Ov, dist, prep, delv, prem, surge, surgetype) {
  if (dist < 0.8) dist = 0.8;

  let longdistanceCharge = 0;
  if (dist > 5) {
    longdistanceCharge = 2 * (pow(dist, 1.23) / 1.2);
    prem = "no";
  }

  let Ddist = 0.69 * math.pow(math.log(13 * dist), 2.53);

  let Ncp;
  if (Ov <= 300) {
    Ncp = 11 + (17 / 4) * math.log(Ov / 16.9);
  } else {
    Ncp = (4350000 - math.pow(Ov, 2)) / 182000;
  }
  if (Ov >= 900)
    Ncp = 17.2;
  Ncp = math.max(math.min(Ncp, 24.0), 18.0);
  const Nc = (Ov / 100) * Ncp;

  let Dov;
  if (Ov <= 100) {
    Dov = math.pow(117 / math.pow(Ov, 0.60), 1.43);
  } else if (Ov <= 200) {
    Dov = math.pow(117 / math.pow(Ov, 0.6), 1.37);
  } else {
    Dov = math.pow(1.7 * math.log(Ov), 1.8) - 35;
  }

  let surgeCharge = 0;
  if (surge === "yes") {
    const surgeMapping = {
      postmidnight: 12,
      rain: 15,
      heatwave: 15,
      traffic: 10,
      cold: 15,
    };
    surgeCharge = surgeMapping[surgetype] || 10;
  }

  const handlingCharges = Ov < 300 ? 1.8 * math.pow(math.log(Ov / 17), 1.58) : math.pow(1.8 * math.pow(math.log(Ov / 15), 1.69), 1.2);
  const packingCharges = Ov >= 300 ? 7 * (Ov / 200) : 8 * (Ov / 200);

  let Ccoins = 0; let DGcoins = 0; let Ncoins = 0;

  if (prep === "late" && delv === "late") {
    Ccoins = Ov > 250 ? (Nc / 100) * 24 + ((Ddist + Dov + handlingCharges) / 100) * 21 : (Nc / 100) * 36 + ((Ddist + Dov + handlingCharges) / 100) * 28;
  } else if (prep === "late" && delv === "ontime") {
    Ccoins = Ov > 250 ? (Nc / 100) * 24 : (Nc / 100) * 36;
    DGcoins = ((Ddist + surgeCharge) / 100) * 51 + (Dov + handlingCharges) / 10;
  } else if (prep === "ontime" && delv === "ontime") {
    DGcoins = ((Ddist + surgeCharge) / 100) * 51 + (Dov + handlingCharges) / 10;
    Ncoins = (Nc / 100) * 28;
  } else if (prep === "ontime" && delv === "late") {
    Ccoins = Ov > 250 ? ((Ddist + Dov + handlingCharges) / 100) * 38 : ((Ddist + Dov + handlingCharges) / 100) * 48;
    Ncoins = (Nc / 100) * 28;
  }
  let Rcoins = Ccoins;

  let UsableCash = Ov > 100 ? (Ov / 100) * (4 + (12 / 4) * math.pow(math.log(Ov / 18), 0.72)) : (Ov / 100) * (5 + (12 / 4) * math.pow(math.log(Ov / 18), 0.89));
  let Rov = Dov, Rdist = Ddist, RhandlingCharges = handlingCharges;
  if (DGcoins > 22) DGcoins = 22;

  if (prem === "yes" && Ov >= 199) {
    Dov = 0;
    Ddist = 0;
    UsableCash = (Ov / 100) * (5 + (12 / 4) * math.pow(math.log(Ov / 18), 0.87));
    Ccoins += 50 * Ccoins / 100;
  }

  if (prem === "yes" && Ov < 199) {
    UsableCash = (Ov / 100) * (7 + (12 / 4) * math.pow(math.log(Ov / 18), 0.99));
    Ccoins += 50 * Ccoins / 100;
  }

  if (prem === "no" && Ov >= 229) {
    Dov = 0;
    Ddist = 0;
  }

  if (UsableCash > 50) UsableCash = 50;
  const Cgst = 5 * (Ov - UsableCash) / 100;

  let shortvalueOrder = 5 + 14 * math.exp((70 - Ov) / 100);
  if (Ov >= 200) shortvalueOrder = 0;

  let dc = 0; let dwc = 0;
  if (Ov >= 300) {
    dc = 65 * (RhandlingCharges) / 100 + 0.35 * Rov + surgeCharge + 0.90 * (shortvalueOrder + longdistanceCharge);
    dwc = 32 * DGcoins / 100;
  } else {
    dc = 72 * (RhandlingCharges) / 100 + 0.38 * Rov + surgeCharge + 0.90 * (shortvalueOrder + longdistanceCharge);
    dwc = 34 * DGcoins / 100;
  }

  const np = (Nc - UsableCash) + (Dov + Ddist + handlingCharges + packingCharges + surgeCharge + shortvalueOrder + longdistanceCharge) - dc - (dwc);

  let epd = 0;
  //if (np > 38) epd = 16 * (np - 32) / 100;
  //if (epd < 5) epd = 0;

  let Ngst = 18 * (np) / 100;
  if (np < 0) Ngst = 0;

  const total = Ov + Dov + Ddist + Cgst + handlingCharges + packingCharges + surgeCharge + shortvalueOrder + longdistanceCharge;
  return {
    order_value: Ov,
    delivery_fee: round(Dov + Ddist),
    dov: round(Dov),
    dDist: round(Ddist),
    surge: round(surgeCharge),
    shortValueOrder: round(shortvalueOrder),
    longDistanceCharge: round(longdistanceCharge),
    packing_charges: round(packingCharges),
    handling_charges: round(handlingCharges),
    gst: round(Cgst),
    total: round(total),
    usable_wallet_cash: round(UsableCash),
    customer_wallet_cash_earned: round(Ccoins),
    nukkad_earning: round(Ov - Nc + epd),
    nukkad_wallet_cash: round(Ncoins),
    total_delivery_boy_earning: round(dc + dwc + shortvalueOrder + (90 * longdistanceCharge / 100)),
    delivery_boy_earning: round(dc + shortvalueOrder + (90 * longdistanceCharge / 100)),
    delivery_boy_wallet_cash: round(dwc + (60 * (2 * epd) / 100)),
    nukkadfoods_comission: round(Nc - epd),
  };
}

function round(value) {
  return Math.round(value * 100) / 100;
}

exports.calculate = functions.https.onCall(async (request, response) => {
  const { order_value, distance, preparation, delivery, premium, surge, surge_type } = request.data;
  try {
    const result = nukkad(
      order_value,
      distance,
      preparation,
      delivery,
      premium,
      surge,
      surge_type || "",
    );
    return result;
  } catch (error) {
    return { "error": error.toString() };
  }
});


exports.allocate = functions.https.onCall(async (request, response) => {
  const { order, restaurant, hubId, user } = request.data;
  try {
    await allocateOrder(order, restaurant, hubId, user);
  } catch (error) {
    console.log(error.toString());
  }
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.sendNotification = functions.https.onCall(async (request, response) => {
  const { uid, title, body, data, channel, toApp } = request.data;
  return await notify(uid, title, body, data, channel, toApp);
});